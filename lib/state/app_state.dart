import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../api/accounts_api.dart' as accounts_api;
import '../api/api_client.dart';
import '../api/payments_api.dart';
import '../api/registration_api.dart';
import '../api/requests_api.dart';
import '../api/security_api.dart';
import '../api/voice_api.dart';
import 'models.dart';

/// Which payment flow a PendingPaymentInfo belongs to — picks the confirm
/// path (REST for barcode, voice "confirm" for the other two) and which
/// submitPin endpoint the PIN sheet calls.
enum PaymentKind { barcode, contact, institution }

/// Small local record of a payment awaiting confirm/PIN — populated from a
/// real server response (barcode scan, or a two-turn send_money /
/// pay_institution dialogue), never scripted.
class PendingPaymentInfo {
  PendingPaymentInfo({
    required this.paymentId,
    required this.kind,
    required this.recipientName,
    required this.amountFormatted,
    required this.replyText,
  });

  final String paymentId;
  final PaymentKind kind;
  final String recipientName;
  final String amountFormatted;
  final String replyText;
}

String _newId() {
  final rand = Random();
  return List.generate(16, (_) => rand.nextInt(16).toRadixString(16)).join();
}

/// Originally a direct port of Wazi.dc.html's scripted `state`/`run()`
/// object. Now network-aware: every "AI response" is a real reply from
/// Wazi-server (POST /voice/query et al.) instead of a canned string on a
/// timer. Copy/branch-shape that's still scripted (onboarding illustrations,
/// the mocked voiceprint-enrollment animation — there's no server endpoint
/// for either) is called out inline below.
class AppState extends ChangeNotifier {
  AppState() {
    _restoreSession();
    _initStt();
  }

  final ApiClient _apiClient = ApiClient();
  late final RegistrationApi registrationApi = RegistrationApi(_apiClient);
  late final accounts_api.AccountsApi accountsApi = accounts_api.AccountsApi(_apiClient);
  late final VoiceApi voiceApi = VoiceApi(_apiClient);
  late final PaymentsApi paymentsApi = PaymentsApi(_apiClient);
  late final SecurityApi securityApi = SecurityApi(_apiClient);
  late final RequestsApi requestsApi = RequestsApi(_apiClient);
  final FlutterTts _tts = FlutterTts();

  /// Client-generated conversation id for /voice/query — the dialogue
  /// ASR session would.
  final String sessionId = _newId();

  AppScreen screen = AppScreen.splash;
  int onb = 0;
  bool listening = false;
  bool processing = false;
  bool isSpeaking = false;
  double soundLevel = 0.0;
  String _sttWords = '';
  final SpeechToText _stt = SpeechToText();
  bool _sttInitialized = false;

  final List<ChatTurn> turns = [];
  final List<ChatTurn> onboardingTurns = [];
  SheetType? sheet;
  String pin = '';
  bool speak = true;
  bool ask = true;
  bool head = false; // "earpiece connected" — demo toggle, skips the privacy check
  bool face = true;
  BankTab tab = BankTab.bank;
  String lang = 'English';
  bool enrolling = false;
  bool enrolled = false;
  String draft = '';

  // --- identity / session --------------------------------------------------
  String? userId;
  RegistrationStatus? regStatus;
  accounts_api.BalanceResponse? balance;
  bool busy = false;
  String? error;

  bool get isSignedIn => userId != null;

  // --- registration flow (auth_screen.dart) --------------------------------
  // 0 phone · 1 OTP · 2 Country · 3 Features · 4 Email · 5 Email OTP · 6 Password · 7 Personal · 8 address · 9 Identity (BVN/NIN) · 10 face · 11 voiceprint · 12 done
  int regStep = 0;

  // --- pending payment (confirm/pin/success sheets) -------------------------
  PendingPaymentInfo? pendingPayment;
  PaymentResult? lastPaymentResult;
  String? paymentError;

  // --- duress / panic PIN (settings screen) ---------------------------------
  DuressStatus? duressStatus;

  // --- inbound contextual voice requests (settings screen) -------------------
  List<MoneyRequestOut>? requestInbox;
  String? requestActionError;

  final List<Timer> _timers = [];

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _later(VoidCallback fn, Duration delay) {
    _timers.add(Timer(delay, fn));
  }

  String get balanceLabel {
    final real = balance?.balanceFormatted ?? '···';
    return (head || !ask) ? real : '₦•••••••';
  }

  // --- session persistence --------------------------------------------------
  static const _prefsUserIdKey = 'wazi_user_id';

  Future<void> _initStt() async {
    _sttInitialized = await _stt.initialize(
      onError: (val) {
        listening = false;
        notifyListeners();
      },
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (listening) {
            listening = false;
            soundLevel = 0.0;
            notifyListeners();
            if (_sttWords.isNotEmpty) {
              final words = _sttWords;
              _sttWords = '';
              if (screen == AppScreen.voiceWelcome) {
                runOnboardingTranscript(words);
              } else if (screen == AppScreen.home) {
                _runTranscript(words);
              }
            }
          }
        }
      },
    );

    _tts.setCompletionHandler(() {
      isSpeaking = false;
      notifyListeners();
      // Auto-start listening after AI speaks on the voice onboarding screen
      if (screen == AppScreen.voiceWelcome) {
        startListening();
      }
    });
    
    _tts.setStartHandler(() {
      isSpeaking = true;
      notifyListeners();
    });
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Always clear session during testing so we start at the Welcome screen
    userId = null;
    await prefs.remove(_prefsUserIdKey);
    
    notifyListeners();
  }

  Future<void> _persistUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsUserIdKey, id);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsUserIdKey);
    userId = null;
    regStatus = null;
    balance = null;
    turns.clear();
    regStep = 0;
    go(AppScreen.welcome);
  }

  void start() {
    _later(() {
      if (screen != AppScreen.splash) return;
      go(userId != null ? AppScreen.home : AppScreen.onboarding);
    }, const Duration(milliseconds: 2400));
  }

  void go(AppScreen s) {
    screen = s;
    sheet = null;
    notifyListeners();
  }

  void _push(ChatRole role, String text, {bool speaking = false}) {
    turns.add(ChatTurn(role: role, text: text, speaking: speaking));
    if (role == ChatRole.ai && speaking) {
      isSpeaking = true;
      notifyListeners();
      _tts.speak(text);
    }
    notifyListeners();
  }

  Future<void> refreshBalance() async {
    if (userId == null) return;
    try {
      balance = await accountsApi.getBalance(userId!);
      notifyListeners();
    } catch (_) {
      // Non-fatal — balanceLabel just shows a placeholder until it succeeds.
    }
  }

  // --- duress / panic PIN ----------------------------------------------------
  Future<void> refreshDuressStatus() async {
    if (userId == null) return;
    try {
      duressStatus = await securityApi.getStatus(userId!);
      notifyListeners();
    } catch (_) {
      // Non-fatal — the settings section just shows "not set" until it
      // succeeds.
    }
  }

  Future<bool> setDuressPin(String pinCode) async {
    if (userId == null) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      duressStatus = await securityApi.setDuressPin(userId!, pinCode);
      return true;
    } on ApiException catch (e) {
      error = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> setTrustedContact(String name, String phoneNumber) async {
    if (userId == null) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      duressStatus = await securityApi.setTrustedContact(userId!, name, phoneNumber);
      return true;
    } on ApiException catch (e) {
      error = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // --- inbound contextual voice requests --------------------------------
  Future<void> refreshRequestInbox() async {
    if (userId == null) return;
    try {
      requestInbox = await requestsApi.getInbox(userId!);
      notifyListeners();
    } catch (_) {
      // Non-fatal — the settings section just shows nothing pending until
      // it succeeds.
    }
  }

  Future<bool> approveRequest(String requestId, String pinCode) async {
    if (userId == null) return false;
    busy = true;
    requestActionError = null;
    notifyListeners();
    try {
      await requestsApi.approve(requestId, userId!, pinCode);
      await refreshRequestInbox();
      await refreshBalance();
      return true;
    } on ApiException catch (e) {
      requestActionError = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> declineRequest(String requestId) async {
    if (userId == null) return false;
    busy = true;
    requestActionError = null;
    notifyListeners();
    try {
      await requestsApi.decline(requestId, userId!);
      await refreshRequestInbox();
      return true;
    } on ApiException catch (e) {
      requestActionError = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // --- onboarding -----------------------------------------------------
  void onbNext() {
    if (onb == 2) {
      go(AppScreen.voiceWelcome);
    } else {
      onb += 1;
      notifyListeners();
    }
  }

  Future<void> runOnboardingTranscript(String transcript) async {
    processing = true;
    error = null;
    notifyListeners();
    
    // Add user's transcript
    onboardingTurns.add(ChatTurn(role: ChatRole.user, text: transcript));
    notifyListeners();
    
    try {
      final response = await voiceApi.onboarding(sessionId: sessionId, transcript: transcript);
      processing = false;
      
      // Add AI's reply
      onboardingTurns.add(ChatTurn(role: ChatRole.ai, text: response.replyText, speaking: speak));
      if (speak) {
        isSpeaking = true;
        notifyListeners();
        _tts.speak(response.replyText);
      }
      notifyListeners();
      
      if (response.clientAction == 'open_camera') {
        // Mock opening camera and scanning document
        _later(() {
          runOnboardingTranscript('document_scanned');
        }, const Duration(seconds: 3));
      } else if (response.clientAction == 'open_bvn_modal') {
        sheet = SheetType.bvn_input;
        notifyListeners();
      } else if (response.clientAction == 'open_nin_modal') {
        sheet = SheetType.nin_input;
        notifyListeners();
      } else if (response.clientAction == 'onboarding_complete') {
        // Give time for the user to hear the final message before navigating away
        _later(() {
          go(AppScreen.home);
        }, const Duration(seconds: 2));
      } else if (response.clientAction == 'fallback_to_traditional') {
        _later(() {
          go(AppScreen.auth);
        }, const Duration(seconds: 2));
      }
      
    } on ApiException catch (e) {
      processing = false;
      error = e.detail;
      onboardingTurns.add(ChatTurn(role: ChatRole.ai, text: "Sorry, I couldn't reach the server: ${e.detail}"));
      if (speak) {
        isSpeaking = true;
        notifyListeners();
        _tts.speak("Sorry, I couldn't reach the server.");
      }
      notifyListeners();
    }
  }

  void submitOnboardingBvn(String typedBvn) {
    sheet = null;
    notifyListeners();
    runOnboardingTranscript("Here is my BVN: $typedBvn");
  }

  void submitOnboardingNin(String typedNin) {
    sheet = null;
    notifyListeners();
    runOnboardingTranscript("Here is my NIN: $typedNin");
  }

  void startListening() async {
    if (!_sttInitialized) return;
    _sttWords = '';
    listening = true;
    soundLevel = 0.0;
    notifyListeners();
    
    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        _sttWords = result.recognizedWords;
      },
      onSoundLevelChange: (level) {
        soundLevel = level;
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(milliseconds: 1500),
      ),
    );
  }

  void stopListening() async {
    await _stt.stop();
    listening = false;
    soundLevel = 0.0;
    notifyListeners();
  }

  void toOnboarding() {
    screen = AppScreen.onboarding;
    onb = 0;
    notifyListeners();
  }

  // --- typing / bank mode ----------------------------------------------
  void toTyping() {
    screen = AppScreen.typing;
    tab = BankTab.bank;
    sheet = null;
    notifyListeners();
  }

  void toBank() {
    tab = BankTab.bank;
    notifyListeners();
  }

  void toChat() {
    screen = AppScreen.typing;
    tab = BankTab.chat;
    sheet = null;
    notifyListeners();
  }

  // --- login (welcome screen "I already have an account") ------------------
  Future<bool> login(String phoneNumber, String password) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      regStatus = await registrationApi.login(phoneNumber, password);
      userId = regStatus!.userId;
      await _persistUserId(userId!);
      await refreshBalance();
      go(AppScreen.dashboard);
      return true;
    } on ApiException catch (e) {
      error = e.detail;
      notifyListeners();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // --- registration steps (auth_screen.dart) --------------------------------
  Future<bool> submitPhoneStep(String phoneNumber) async {
    busy = true; error = null; notifyListeners();
    try {
      await registrationApi.startPhone(phoneNumber);
      regStep = 1;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitPhoneOtpStep(String phoneNumber, String otp) async {
    busy = true; error = null; notifyListeners();
    try {
      regStatus = await registrationApi.verifyPhone(phoneNumber, otp);
      userId = regStatus!.userId;
      await _persistUserId(userId!);
      regStep = 2;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitCountryStep(String country) async {
    if (userId == null) return false;
    busy = true; error = null; notifyListeners();
    try {
      regStatus = await registrationApi.submitCountry(userId!, country);
      regStep = 3;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitEmailStep(String email) async {
    if (userId == null) return false;
    busy = true; error = null; notifyListeners();
    try {
      await registrationApi.startEmail(userId!, email);
      regStep = 5;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitEmailOtpStep(String email, String otp) async {
    if (userId == null) return false;
    busy = true; error = null; notifyListeners();
    try {
      regStatus = await registrationApi.verifyEmail(userId!, email, otp);
      regStep = 6;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitPasswordStep(String password) async {
    if (userId == null) return false;
    busy = true; error = null; notifyListeners();
    try {
      regStatus = await registrationApi.submitPassword(userId!, password);
      regStep = 7;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitPersonalDetailsStep(String firstName, String lastName, String? otherName, String dob, String gender) async {
    if (userId == null) return false;
    busy = true; error = null; notifyListeners();
    try {
      regStatus = await registrationApi.submitProfileDetails(userId!, firstName, lastName, otherName, dob, gender);
      regStep = 8;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitBvnStep(String bvn) async {
    if (userId == null) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      regStatus = await registrationApi.submitBvn(userId!, bvn);
      return true;
    } on ApiException catch (e) {
      error = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> submitNinStep(String nin) async {
    if (userId == null) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      regStatus = await registrationApi.submitNin(userId!, nin);
      return true;
    } on ApiException catch (e) {
      error = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void completeIdentityVerification() {
    regStep = 11;
    notifyListeners();
  }

  /// Address capture is mocked — no real document upload backend, same
  /// "Simulate ___" pattern as the Scan screen's barcode step. `documentRef`
  /// is a client-made-up reference id.
  Future<bool> submitAddressStep() async {
    if (userId == null) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      regStatus = await registrationApi.submitAddress(userId!, 'addr_${userId}_utility_bill');
      regStep = 9; // proceed to Identity Verification
      return true;
    } on ApiException catch (e) {
      error = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Mocked face capture — see app/face/mock_adapter.py's sample-id
  /// convention. A real capture flow would produce this id from an actual
  /// liveness+match SDK; here the client just constructs the convention.
  Future<bool> submitFaceStep() async {
    if (userId == null) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      regStatus = await registrationApi.submitFace(userId!, 'face_${userId}_ok');
      regStep = 12;
      return true;
    } on ApiException catch (e) {
      error = e.detail;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void skipRegStep() {
    if (regStep >= 9 && regStep < 11) regStep += 1;
    notifyListeners();
  }

  Future<bool> submitVoiceStep() async {
    if (userId == null) return false;
    busy = true; error = null; notifyListeners();
    try {
      regStatus = await registrationApi.submitVoice(userId!, 'voice_mock_123');
      regStep = 13;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> submitPinSetup(String pin) async {
    if (userId == null) return false;
    busy = true; error = null; notifyListeners();
    try {
      regStatus = await registrationApi.submitTransactionPin(userId!, pin);
      regStep = 14;
      return true;
    } on ApiException catch (e) {
      error = e.detail; return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> finishRegistration() async {
    await refreshBalance();
    regStep = 15;
    go(AppScreen.dashboard);
    return true;
  }

  // --- voiceprint enrollment (auth screen, step 5) --------------------------
  // No server endpoint: MockVoiceprintAdapter matches by sample-id
  // convention only, there's nothing to "enroll" — this stays the design's
  // own scripted capture animation.
  void startEnroll() {
    enrolling = true;
    notifyListeners();
    _later(() {
      enrolling = false;
      enrolled = true;
      notifyListeners();
    }, const Duration(milliseconds: 2200));
  }

  // --- toggles -----------------------------------------------------------
  void toggleSpeak() {
    speak = !speak;
    notifyListeners();
  }

  void toggleAsk() {
    ask = !ask;
    notifyListeners();
  }

  void toggleHead() {
    head = !head;
    notifyListeners();
  }

  void toggleFace() {
    face = !face;
    notifyListeners();
  }

  void pickLang(String name) {
    lang = name;
    notifyListeners();
  }

  // --- sheets --------------------------------------------------------------
  void dismiss() {
    sheet = null;
    pin = '';
    paymentError = null;
    notifyListeners();
  }

  void openPin() {
    sheet = SheetType.pin;
    pin = '';
    paymentError = null;
    notifyListeners();
  }

  Map<String, dynamic>? selectedNotification;

  void openNotif() => go(AppScreen.notifications);

  void openNotificationDetails(Map<String, dynamic> notif) {
    selectedNotification = notif;
    go(AppScreen.notificationDetails);
  }

  void openSupport() {
    sheet = SheetType.support;
    notifyListeners();
  }

  void privacyAloud() {
    sheet = null;
    if (balance != null) {
      _push(ChatRole.ai, balance!.narration, speaking: true);
    }
  }

  void privacyScreen() {
    sheet = null;
    if (balance != null) {
      _push(ChatRole.ai, 'On screen only: ${balance!.balanceFormatted}.');
    }
  }

  void finishSuccess() {
    sheet = null;
    screen = AppScreen.home;
    pendingPayment = null;
    notifyListeners();
    if (lastPaymentResult != null) {
      _push(ChatRole.ai, lastPaymentResult!.replyText, speaking: speak);
    }
  }

  /// "Simulate code found" on the scan screen — a real POST
  /// /payments/barcode/scan against a fixture merchant, not a scripted
  /// string. See app/payments/fixtures.py for what NQR-AMALA-JOINT-001 is.
  Future<void> scanFound() async {
    if (userId == null) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final result = await paymentsApi.scanBarcode(userId!, 'NQR-AMALA-JOINT-001');
      pendingPayment = PendingPaymentInfo(
        paymentId: result.paymentId,
        kind: PaymentKind.barcode,
        recipientName: result.recipientName,
        amountFormatted: result.amountFormatted,
        replyText: result.replyText,
      );
      sheet = SheetType.confirm;
    } on ApiException catch (e) {
      error = e.detail;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Confirm sheet's "Confirm" button — real POST .../confirm with
  /// transcript "confirm" (the literal word the server's confirm() checks
  /// for), for whichever payment kind is pending.
  Future<void> confirmPendingPayment() async {
    final pending = pendingPayment;
    if (pending == null || userId == null) return;
    busy = true;
    notifyListeners();
    try {
      if (pending.kind == PaymentKind.barcode) {
        final result = await paymentsApi.confirmBarcode(pending.paymentId, userId!, 'confirm');
        pendingPayment = PendingPaymentInfo(
          paymentId: result.paymentId,
          kind: PaymentKind.barcode,
          recipientName: result.recipientName,
          amountFormatted: result.amountFormatted,
          replyText: result.replyText,
        );
        if (result.status == 'awaiting_pin') {
          openPin();
        } else {
          sheet = null;
        }
      } else {
        // Contact and institution payments are both confirmed by voice —
        // the dialogue manager routes on the session's pending payment
        // type, not anything the client needs to distinguish here.
        final turn = await voiceApi.query(sessionId: sessionId, userId: userId!, transcript: 'Confirm');
        _push(ChatRole.ai, turn.replyText, speaking: speak);
        sheet = null;
        if (turn.data?['status'] == 'awaiting_pin') {
          openPin();
        }
      }
    } on ApiException catch (e) {
      error = e.detail;
      sheet = null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // --- PIN keypad ----------------------------------------------------------
  void keyPress(String v) {
    if (v == '⌫') {
      if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      notifyListeners();
      return;
    }
    if (v.isEmpty) return;
    pin = (pin + v);
    if (pin.length > 4) pin = pin.substring(0, 4);
    notifyListeners();
    if (pin.length == 4) {
      _submitPendingPin();
    }
  }

  Future<void> _submitPendingPin() async {
    final pending = pendingPayment;
    if (pending == null || userId == null) return;
    final enteredPin = pin;
    busy = true;
    paymentError = null;
    notifyListeners();
    try {
      final result = switch (pending.kind) {
        PaymentKind.barcode => await paymentsApi.submitBarcodePin(pending.paymentId, userId!, enteredPin),
        PaymentKind.contact => await paymentsApi.submitContactPin(pending.paymentId, userId!, enteredPin),
        PaymentKind.institution => await paymentsApi.submitInstitutionPin(pending.paymentId, userId!, enteredPin),
      };
      lastPaymentResult = result;
      pin = '';
      if (result.status == 'completed') {
        sheet = SheetType.success;
        await refreshBalance();
      } else {
        // Cancelled — wrong PIN too many times, tier limit exceeded, etc.
        sheet = null;
        _push(ChatRole.ai, result.replyText, speaking: speak);
      }
    } on ApiException catch (e) {
      paymentError = e.detail;
      pin = '';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // --- chat text input -------------------------------------------------
  void setDraft(String v) {
    draft = v;
    notifyListeners();
  }

  void sendDraft() {
    final d = draft.trim();
    if (d.isEmpty) return;
    draft = '';
    notifyListeners();
    _runTranscript(d);
  }

  // --- voice flows ---------------------------------------------------------
  void onMic() {
    if (listening) {
      stopListening();
      return;
    }
    startListening();
  }

  static const _kindPhrases = {
    'send': 'Send 2,000 naira to Tunde',
    'balance': "What's my balance?",
    'spend': 'Where did my money go this month?',
    'scan': 'Scan this to pay',
    'budget': 'Cap my transport at 100000 naira a month',
    'pay_fees': 'Pay school fees at Kings College 5000 naira',
    'request': 'I need 1000 naira from Mum for data, due Friday',
  };

  void run(String kind) => _runTranscript(_kindPhrases[kind] ?? kind);

  /// The real ASR->NLU->reply round trip: push what the user "said", call
  /// POST /voice/query, push whatever Wazi-server actually says back.
  Future<void> _runTranscript(String transcript) async {
    if (userId == null) return;
    processing = true;
    if (screen != AppScreen.insights) screen = AppScreen.home;
    sheet = null;
    notifyListeners();
    _push(ChatRole.user, transcript);

    try {
      final turn = await voiceApi.query(sessionId: sessionId, userId: userId!, transcript: transcript);
      processing = false;
      notifyListeners();

      if (turn.intent == 'check_balance' && !turn.needsClarification) {
        if (head || !ask) {
          _push(ChatRole.ai, turn.replyText, speaking: speak);
          if (turn.data != null) {
            balance = accounts_api.BalanceResponse.fromJson(turn.data!);
            notifyListeners();
          }
        } else {
          if (turn.data != null) balance = accounts_api.BalanceResponse.fromJson(turn.data!);
          sheet = SheetType.privacy;
          notifyListeners();
        }
        return;
      }

      _push(ChatRole.ai, turn.replyText, speaking: speak);

      if (turn.intent == 'spend_summary' && !turn.needsClarification) {
        _later(() => go(AppScreen.insights), const Duration(milliseconds: 900));
        return;
      }

      if (turn.intent == 'scan_barcode' && !turn.needsClarification) {
        _later(() => go(AppScreen.scan), const Duration(milliseconds: 700));
        return;
      }

      if (turn.intent == 'send_money' && turn.data?['status'] == 'awaiting_confirmation') {
        pendingPayment = PendingPaymentInfo(
          paymentId: turn.data!['payment_id'] as String,
          kind: PaymentKind.contact,
          recipientName: turn.data!['contact_name'] as String,
          amountFormatted: turn.data!['amount_formatted'] as String,
          replyText: turn.replyText,
        );
        _later(() {
          sheet = SheetType.confirm;
          notifyListeners();
        }, const Duration(milliseconds: 700));
      }

      // Diaspora direct-to-obligation payments — "pay school fees at
      // Kings College" — same two-turn confirm shape as send_money, just
      // to a verified institution instead of a saved contact.
      if (turn.intent == 'pay_institution' && turn.data?['status'] == 'awaiting_confirmation') {
        pendingPayment = PendingPaymentInfo(
          paymentId: turn.data!['payment_id'] as String,
          kind: PaymentKind.institution,
          recipientName: turn.data!['institution_name'] as String,
          amountFormatted: turn.data!['amount_formatted'] as String,
          replyText: turn.replyText,
        );
        _later(() {
          sheet = SheetType.confirm;
          notifyListeners();
        }, const Duration(milliseconds: 700));
      }
    } on ApiException catch (e) {
      processing = false;
      error = e.detail;
      _push(ChatRole.ai, "Sorry, I couldn't reach the server: ${e.detail}");
    }
  }

  void askSend() => run('send');
  void askBalance() => run('balance');
  void askSpend() => run('spend');
  void askScan() => run('scan');
  void askBudget() => run('budget');
  void askPayFees() => run('pay_fees');
  void askRequestMoney() => run('request');
}
