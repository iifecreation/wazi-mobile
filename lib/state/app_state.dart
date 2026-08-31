import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../api/accounts_api.dart' as accounts_api;
import '../api/api_client.dart';
import '../api/payments_api.dart';
import '../api/registration_api.dart';
import '../api/requests_api.dart';
import '../api/notifications_api.dart';
import '../api/cards_api.dart';
import '../api/finance_api.dart';
import '../api/savings_api.dart';
import '../api/bills_api.dart';
import '../api/security_api.dart';
import '../api/transcription_api.dart';
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
  late final NotificationsApi notificationsApi = NotificationsApi(_apiClient);
  late final CardsApi cardsApi = CardsApi(_apiClient);
  late final FinanceApi financeApi = FinanceApi(_apiClient);
  late final SavingsApi savingsApi = SavingsApi(_apiClient);
  late final BillsApi billsApi = BillsApi(_apiClient);
  late final TranscriptionApi transcriptionApi = TranscriptionApi(_apiClient);
  final FlutterTts _tts = FlutterTts();
  final AudioRecorder _recorder = AudioRecorder();
  // Flips true the first time the server reports no transcription
  // provider is configured (503) — that isn't going to change
  // mid-session, so this stops adding a doomed upload attempt (and its
  // latency) to every remaining turn. Recognition still works via the
  // on-device fallback.
  bool _cloudTranscriptionUnavailable = false;
  // iOS (and most Android configurations) won't let two separate
  // microphone sessions run at once — `record`'s own capture and
  // speech_to_text's live recognition fighting over the mic is exactly
  // what silently produced zero-length recordings when this app tried to
  // run both in parallel. So there's exactly one owner of the mic at a
  // time: the recorder (primary, feeds cloud/Whisper transcription) or
  // speech_to_text (fallback, only when the recorder can't be used or
  // cloud transcription fails outright).
  StreamSubscription<Amplitude>? _ampSub;
  DateTime? _speechDetectedAt;
  DateTime? _lastLoudAt;
  Timer? _maxDurationTimer;
  bool _usingOnDeviceFallback = false;
  static const _silenceThresholdDb = -35.0;
  static const _silenceStopAfter = Duration(seconds: 3);
  static const _maxRecordingDuration = Duration(seconds: 25);

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
  // Preferred locale for recognition, resolved once at startup (see
  // _initStt) — a Nigerian English locale if the device offers one,
  // otherwise null (device default). Passing the *wrong* locale to a
  // correctly-working recognizer is a common, easy-to-miss cause of
  // "it doesn't understand me even though I'm speaking clearly".
  String? _preferredLocaleId;

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
    _ampSub?.cancel();
    _maxDurationTimer?.cancel();
    _recorder.dispose();
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
        // Only the on-device fallback path uses _stt.listen() now — the
        // primary path (see startListening) records via `record` instead,
        // since iOS won't run both microphone sessions at once.
        if ((val == 'done' || val == 'notListening') && listening && _usingOnDeviceFallback) {
          listening = false;
          soundLevel = 0.0;
          notifyListeners();
          final words = _sttWords;
          _sttWords = '';
          if (words.isNotEmpty) _dispatchTranscript(words);
        }
      },
    );

    if (_sttInitialized) {
      try {
        final locales = await _stt.locales();
        final nigerian = locales.where((l) => l.localeId.toLowerCase().contains('ng')).toList();
        if (nigerian.isNotEmpty) {
          _preferredLocaleId = nigerian.first.localeId;
        }
      } catch (_) {
        // Non-fatal — falls back to the device's default locale.
      }
    }

    _tts.setCompletionHandler(() {
      isSpeaking = false;
      notifyListeners();
      // Auto-relisten after Wazi finishes speaking, on both the voice
      // onboarding screen and the logged-in voice screen (same
      // VoiceScreen widget, see app_root.dart) — this is what makes a
      // voice conversation actually flow: onboarding, "what's my
      // balance", "send 2000 to Tunde", airtime, all keep listening for
      // the next thing to say without a manual tap every turn. A manual
      // tap (toggleListening, wired to the mic button) still works at any
      // point, including to interrupt.
      if (screen == AppScreen.voiceWelcome || screen == AppScreen.home) {
        startListening();
      }
    });
    
    _tts.setStartHandler(() {
      isSpeaking = true;
      notifyListeners();
    });

    await _applyTtsLanguage();
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

      // The channel's only way to learn its user_id — set as soon as the
      // draft account exists (right after phone verification), long
      // before the flow completes.
      if (response.userId != null) {
        userId = response.userId;
      }

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
      } else if (response.clientAction == 'open_password_modal') {
        sheet = SheetType.password_input;
        notifyListeners();
      } else if (response.clientAction == 'open_pin_modal') {
        sheet = SheetType.transaction_pin_input;
        notifyListeners();
      } else if (response.clientAction == 'onboarding_complete') {
        if (userId != null) {
          await _persistUserId(userId!);
          await refreshBalance();
        }
        // Give time for the user to hear the final message before navigating away
        _later(() {
          go(AppScreen.dashboard);
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

  /// Login password — typed via modal, never spoken, same reasoning as
  /// BVN/NIN above. See app/dialogue/onboarding.py's module docstring.
  void submitOnboardingPassword(String typedPassword) {
    sheet = null;
    notifyListeners();
    runOnboardingTranscript("Here is my password: $typedPassword");
  }

  /// Transaction PIN — the credential that actually authorizes payments
  /// (separate from the login password above). Typed via modal, never
  /// spoken, same reasoning as everywhere else money-adjacent in this app.
  void submitOnboardingTransactionPin(String typedPin) {
    sheet = null;
    notifyListeners();
    runOnboardingTranscript("Here is my PIN: $typedPin");
  }

  void _dispatchTranscript(String words) {
    if (screen == AppScreen.voiceWelcome) {
      runOnboardingTranscript(words);
    } else if (screen == AppScreen.home) {
      _runTranscript(words);
    }
  }

  /// Entry point for a listening turn — tries the recorder-backed path
  /// first (cloud/Whisper transcription, generally more accurate and the
  /// only path that understands Nigerian-accented English well), and
  /// falls back to on-device recognition only if the recorder itself
  /// can't start. The two never run at once (see the field comments above
  /// on why).
  void startListening() async {
    if (!_sttInitialized) return;
    listening = true;
    soundLevel = 0.0;
    _usingOnDeviceFallback = false;
    notifyListeners();

    final started = await _startRecordingCapture();
    if (!started) {
      await _startOnDeviceListening();
    }
  }

  Future<bool> _startRecordingCapture() async {
    try {
      if (!await _recorder.hasPermission()) return false;
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/wazi_turn_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1), path: path);

      _speechDetectedAt = null;
      _lastLoudAt = null;
      _ampSub?.cancel();
      _ampSub = _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen((amp) {
        soundLevel = amp.current;
        notifyListeners();
        final now = DateTime.now();
        if (amp.current > _silenceThresholdDb) {
          _speechDetectedAt ??= now;
          _lastLoudAt = now;
        } else if (_speechDetectedAt != null && _lastLoudAt != null && now.difference(_lastLoudAt!) >= _silenceStopAfter) {
          _endRecordingCapture();
        }
      });

      _maxDurationTimer?.cancel();
      _maxDurationTimer = Timer(_maxRecordingDuration, _endRecordingCapture);
      return true;
    } catch (_) {
      // No mic permission for `record`, or the platform recorder failed
      // to start — the on-device fallback still carries this turn.
      return false;
    }
  }

  void _endRecordingCapture() {
    if (!listening || _usingOnDeviceFallback) return; // already handled
    _ampSub?.cancel();
    _ampSub = null;
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    listening = false;
    soundLevel = 0.0;
    notifyListeners();
    _finishRecordingCapture();
  }

  Future<void> _finishRecordingCapture() async {
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      // Nothing to upload — go straight to the fallback.
    }
    if (path == null) {
      await _startOnDeviceListening();
      return;
    }

    final file = File(path);
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || _cloudTranscriptionUnavailable) {
        await _startOnDeviceListening();
        return;
      }
      final transcript = await transcriptionApi
          .transcribe(bytes, languageCode: _langLocaleCodes[lang] ?? 'en-NG')
          .timeout(const Duration(seconds: 15));
      final words = transcript.trim();
      if (words.isEmpty) {
        await _startOnDeviceListening();
        return;
      }
      _dispatchTranscript(words);
    } on ApiException catch (e) {
      // 503 = server has no transcription provider configured — stop
      // trying for the rest of this session. Any other status (bad
      // audio, provider hiccup) just falls back for this turn.
      if (e.statusCode == 503) _cloudTranscriptionUnavailable = true;
      await _startOnDeviceListening();
    } catch (_) {
      // Network error / timeout.
      await _startOnDeviceListening();
    } finally {
      unawaited(file.delete().catchError((_) => file));
    }
  }

  /// Fallback path — the phone's built-in recognizer, live-listening the
  /// same way this app always used to. Only reached when the recorder
  /// can't start at all, or cloud transcription fails outright for a turn
  /// that was already recorded.
  Future<void> _startOnDeviceListening() async {
    if (!_sttInitialized) {
      listening = false;
      notifyListeners();
      return;
    }
    _usingOnDeviceFallback = true;
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
        // `dictation` (built for full natural sentences, like the
        // keyboard's dictation button) instead of the default
        // `confirmation` mode (tuned for short yes/no-style utterances) —
        // confirmation mode was very likely the real cause of getting cut
        // off mid-sentence, not the pause timing.
        listenMode: ListenMode.dictation,
        // 1.5s was too tight — a normal pause mid-sentence (thinking of
        // the next word, a slower/deliberate speaking pace) reads as
        // "done talking" and cuts the user off. 3s gives real breathing
        // room without making every turn feel like it hangs forever.
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
        partialResults: true,
        cancelOnError: false,
        localeId: _preferredLocaleId,
      ),
    );
  }

  void stopListening() async {
    if (_usingOnDeviceFallback) {
      await _stt.stop();
    } else {
      _endRecordingCapture();
    }
  }

  /// The mic button's onTap — the manual fallback to the auto-relisten
  /// loop above. Stops a listening turn early if already listening,
  /// otherwise starts one. Also usable to interrupt Wazi mid-sentence:
  /// stopping TTS first so it doesn't keep talking over the user.
  void toggleListening() {
    if (isSpeaking) {
      _tts.stop();
      isSpeaking = false;
    }
    if (listening) {
      stopListening();
    } else {
      startListening();
    }
  }

  void toOnboarding() {
    screen = AppScreen.onboarding;
    onb = 0;
    notifyListeners();
  }

  // --- typing / bank mode ----------------------------------------------


  void toBank() {
    tab = BankTab.bank;
    notifyListeners();
  }

  void toChat() {
    screen = AppScreen.home;
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

  // Best-effort locale codes for each language Settings offers. Real
  // constraint worth being upfront about: which of these actually speak
  // out loud depends on what voice packs are installed on the device —
  // Apple/Android don't ship on-device TTS voices for Yoruba, Igbo, Hausa,
  // or Nigerian Pidgin at all as of this writing, only for a handful of
  // major world languages. `_applyTtsLanguage` checks availability first
  // and falls back to English rather than silently saying nothing (or
  // speaking in the wrong language) when a voice isn't on the device.
  static const _langLocaleCodes = {
    'English': 'en-NG',
    'Pidgin': 'en-NG', // no distinct TTS locale for Nigerian Pidgin exists
    'Yoruba': 'yo-NG',
    'Igbo': 'ig-NG',
    'Hausa': 'ha-NG',
    'Swahili': 'sw-KE',
    'French': 'fr-FR',
  };

  Future<void> _applyTtsLanguage() async {
    final code = _langLocaleCodes[lang] ?? 'en-US';
    var resolvedCode = 'en-US';
    try {
      final available = await _tts.isLanguageAvailable(code);
      resolvedCode = available == true ? code : 'en-US';
      await _tts.setLanguage(resolvedCode);
    } catch (_) {
      // Non-fatal — keep whatever language the engine already has set.
    }
    await _applyBestVoice(resolvedCode);
    try {
      // A touch slower than the engine default, at a natural (not
      // artificially raised/lowered) pitch — the default rate on iOS in
      // particular reads as rushed/flat, which is a real part of what
      // makes a voice sound obviously synthetic.
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.46);
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Picks the most natural-sounding installed voice for a locale. iOS
  /// ships each language in multiple quality tiers — "default" (the
  /// older, noticeably synthetic-sounding compact voices), "enhanced",
  /// and "premium" (Apple's neural voices, genuinely close to a human
  /// speaker) — but only the "default" tier is pre-installed; enhanced/
  /// premium voices have to be downloaded once by the *user*, in
  /// Settings -> Accessibility -> Spoken Content -> Voices -> (language)
  /// -> pick a voice tagged "Enhanced" or "Premium". This just makes sure
  /// the app actually uses the best one already on the device instead of
  /// defaulting to the compact voice — it can't download one itself.
  Future<void> _applyBestVoice(String localeCode) async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return;
      final languagePrefix = localeCode.split('-').first.toLowerCase();
      final matches = raw
          .whereType<Object>()
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((v) => (v['locale'] as String? ?? '').toLowerCase().startsWith(languagePrefix))
          .toList();
      if (matches.isEmpty) return;

      const qualityRank = {'premium': 0, 'enhanced': 1, 'default': 2};
      matches.sort((a, b) {
        final qa = qualityRank[(a['quality'] as String? ?? 'default').toLowerCase()] ?? 3;
        final qb = qualityRank[(b['quality'] as String? ?? 'default').toLowerCase()] ?? 3;
        return qa.compareTo(qb);
      });

      final best = matches.first;
      await _tts.setVoice({
        'name': best['name'] as String? ?? '',
        'locale': best['locale'] as String? ?? localeCode,
        if (best['identifier'] is String) 'identifier': best['identifier'] as String,
      });
    } catch (_) {
      // Non-fatal — falls back to whatever voice the engine already had
      // selected for this language.
    }
  }

  void pickLang(String name) {
    lang = name;
    notifyListeners();
    _applyTtsLanguage();
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
    if (transcript.trim().isEmpty) {
      // The screen's own kick-off call (see voice_screen.dart's initState)
      // — a real greeting belongs here, not "Sorry, I didn't catch that"
      // (which is what the server's rule-based parser would say to an
      // empty transcript, since no keyword rule matches nothing). No
      // network round trip needed for a canned greeting.
      if (turns.isEmpty) {
        _push(ChatRole.ai, "Hi, I'm listening. Ask for a balance, send money, buy airtime — whatever you need.", speaking: speak);
      }
      return;
    }
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
