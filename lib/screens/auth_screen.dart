import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api/registration_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pin_dots.dart';
import '../widgets/pulse_ring.dart';

/// Multi-step account creation, wired to the real POST /registration/*
/// endpoints: phone+PIN -> BVN -> NIN -> proof of address -> face -> the
/// existing (mocked, no server counterpart) voiceprint capture -> done.
/// Each KYC step is real and moves the account up Nigeria's CBN-style
/// tiers (see app/registration/interfaces.py): BVN alone reaches Tier 1,
/// BVN+NIN reaches Tier 2, +address reaches Tier 3. BVN/NIN/address/face
/// verification themselves are mocked — no real licensed KYC provider —
/// same posture as the rest of this backend.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _bvnController = TextEditingController();
  final _ninController = TextEditingController();
  String _pin = '';
  String _pinConfirm = '';
  bool _settingConfirm = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _bvnController.dispose();
    _ninController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: AnimatedBuilder(
          animation: widget.appState,
          builder: (context, _) {
            final appState = widget.appState;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.welcome),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 4),
                if (appState.regStatus != null) _TierBadge(status: appState.regStatus!),
                const SizedBox(height: 12),
                _stepBody(appState),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stepBody(AppState appState) {
    switch (appState.regStep) {
      case 0:
        return _phonePinStep(appState);
      case 1:
        return _kycTextStep(
          appState: appState,
          title: 'Verify your BVN',
          label: 'BANK VERIFICATION NUMBER',
          hint: '11 digits',
          controller: _bvnController,
          onSubmit: () => appState.submitBvnStep(_bvnController.text.trim()),
        );
      case 2:
        return _kycTextStep(
          appState: appState,
          title: 'Verify your NIN',
          label: 'NATIONAL IDENTITY NUMBER',
          hint: '11 digits',
          controller: _ninController,
          onSubmit: () => appState.submitNinStep(_ninController.text.trim()),
        );
      case 3:
        return _mockCaptureStep(
          appState: appState,
          title: 'Confirm your address',
          body: 'Upload a recent utility bill or bank statement — we\'ll match it to your BVN details.',
          buttonLabel: 'Simulate document uploaded',
          onSubmit: appState.submitAddressStep,
        );
      case 4:
        return _mockCaptureStep(
          appState: appState,
          title: 'Face verification',
          body: 'Take a quick selfie so we know it\'s really you opening this account.',
          buttonLabel: 'Simulate face captured',
          onSubmit: appState.submitFaceStep,
        );
      default:
        return _voiceprintStep(appState);
    }
  }

  Widget _phonePinStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set up your account', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 26),
        _label('PHONE NUMBER'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: Row(
            children: [
              Text('+234', style: WaziText.grotesk(size: 15, weight: FontWeight.w500, color: WaziColors.textAt(.6))),
              const SizedBox(width: 10),
              Container(width: 1, height: 20, color: WaziColors.textAt(.14)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '802 431 9902',
                    hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0, color: WaziColors.textAt(.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _label(_settingConfirm ? 'CONFIRM 4-DIGIT PIN' : 'CREATE 4-DIGIT PIN'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: PinDots(length: _settingConfirm ? _pinConfirm.length : _pin.length, filled: false),
        ),
        const SizedBox(height: 10),
        _MiniKeypad(
          onKey: (v) {
            setState(() {
              if (_settingConfirm) {
                if (v == '⌫') {
                  if (_pinConfirm.isNotEmpty) _pinConfirm = _pinConfirm.substring(0, _pinConfirm.length - 1);
                } else if (_pinConfirm.length < 4) {
                  _pinConfirm += v;
                }
              } else {
                if (v == '⌫') {
                  if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
                } else if (_pin.length < 4) {
                  _pin += v;
                  if (_pin.length == 4) _settingConfirm = true;
                }
              }
            });
          },
        ),
        if (_settingConfirm && _pinConfirm.length == 4 && _pinConfirm != _pin) ...[
          const SizedBox(height: 10),
          Text("PINs don't match — try again.", style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        if (appState.error != null) ...[
          const SizedBox(height: 10),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmitPhonePin(appState) ? () => appState.registerStart('+234${_phoneController.text.trim()}', _pin) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text('Continue', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  bool _canSubmitPhonePin(AppState appState) =>
      !appState.busy && _phoneController.text.trim().isNotEmpty && _pin.length == 4 && _pinConfirm.length == 4 && _pin == _pinConfirm;

  Widget _kycTextStep({
    required AppState appState,
    required String title,
    required String label,
    required String hint,
    required TextEditingController controller,
    required Future<bool> Function() onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text(
          'Mocked verification for this build — no real BVN/NIN lookup happens. Any 11 digits pass except 00000000000.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 22),
        _label(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 11,
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
            decoration: InputDecoration(border: InputBorder.none, counterText: '', hintText: hint, hintStyle: WaziText.inter(size: 15, color: WaziColors.textAt(.3))),
          ),
        ),
        if (appState.error != null) ...[
          const SizedBox(height: 10),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (!appState.busy && controller.text.trim().length == 11) ? () => onSubmit() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text('Verify', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: appState.busy ? null : appState.skipRegStep,
            child: Text('Skip for now', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5))),
          ),
        ),
      ],
    );
  }

  Widget _mockCaptureStep({
    required AppState appState,
    required String title,
    required String body,
    required String buttonLabel,
    required Future<bool> Function() onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text(body, style: WaziText.inter(size: 14, color: WaziColors.textAt(.6), height: 1.4)),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: WaziColors.card,
            border: Border.all(color: WaziColors.textAt(.1), style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.camera_alt_outlined, size: 34, color: WaziColors.textAt(.3)),
        ),
        if (appState.error != null) ...[
          const SizedBox(height: 10),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: appState.busy ? null : () => onSubmit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text(buttonLabel, style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: appState.busy ? null : appState.skipRegStep,
            child: Text('Skip for now', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5))),
          ),
        ),
      ],
    );
  }

  Widget _voiceprintStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last step', style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        _VoiceprintCard(appState: appState),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => appState.finishRegistration(),
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Finish setup', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text, style: WaziText.inter(size: 12, color: WaziColors.textAt(.45), letterSpacing: 1.2));
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.status});

  final RegistrationStatus status;

  @override
  Widget build(BuildContext context) {
    final limits = status.limits;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: WaziColors.tealAt(.1),
        border: Border.all(color: WaziColors.tealAt(.3)),
      ),
      child: Row(
        children: [
          Text('TIER ${status.tier}', style: WaziText.grotesk(size: 12, weight: FontWeight.w700, color: WaziColors.teal, letterSpacing: 1.2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Daily limit ${limits.dailyLimitFormatted}${limits.maxBalanceFormatted != null ? ' · Balance up to ${limits.maxBalanceFormatted}' : ''}',
              style: WaziText.inter(size: 12, color: WaziColors.textAt(.6)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniKeypad extends StatelessWidget {
  const _MiniKeypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: _keys.map((k) {
        return GestureDetector(
          onTap: k.isEmpty ? null : () => onKey(k),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: k.isEmpty ? Colors.transparent : WaziColors.textAt(.06)),
            alignment: Alignment.center,
            child: Text(k, style: WaziText.grotesk(size: 18, weight: FontWeight.w500)),
          ),
        );
      }).toList(),
    );
  }
}

class _VoiceprintCard extends StatelessWidget {
  const _VoiceprintCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final status = appState.enrolled
        ? 'Voiceprint saved — 2 of 2 recorded'
        : (appState.enrolling ? 'Listening… keep talking' : 'Tap to record · about 4 seconds');
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: [WaziColors.tealAt(.13), WaziColors.tealAt(.03)]),
        border: Border.all(color: WaziColors.tealAt(.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VOICEPRINT', style: WaziText.grotesk(size: 12, weight: FontWeight.w600, color: WaziColors.teal, letterSpacing: 1.7)),
              Text('Step 2 of 2', style: WaziText.inter(size: 11, color: WaziColors.tealAt(.7))),
            ],
          ),
          const SizedBox(height: 8),
          Text('Record your phrase', style: WaziText.grotesk(size: 21, weight: FontWeight.w600, letterSpacing: -0.2)),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.6), height: 1.4),
              children: [
                const TextSpan(text: 'Say '),
                TextSpan(text: '"My voice is my key at Wazi"', style: TextStyle(color: WaziColors.text)),
                const TextSpan(text: ' twice. This tells us it\'s you — your PIN still approves every payment.'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              GestureDetector(
                onTap: appState.startEnroll,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (appState.enrolling)
                        PulseRing(color: WaziColors.teal, size: 60, duration: const Duration(milliseconds: 1600), maxScale: 1.35, startOpacity: 1.0),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.teal),
                        alignment: Alignment.center,
                        child: Container(width: 12, height: 22, decoration: BoxDecoration(color: WaziColors.bg, borderRadius: BorderRadius.circular(7))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(18, (i) {
                      final h = appState.enrolling
                          ? 8 + (26 * (math.sin(i * 1.1)).abs()).round()
                          : (appState.enrolled ? 6 + (20 * (math.sin(i * 0.8)).abs()).round() : 4);
                      return Expanded(
                        child: Container(
                          height: h.toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: appState.enrolling ? WaziColors.teal : WaziColors.tealAt(.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(status, style: WaziText.inter(size: 12.5, color: WaziColors.teal)),
        ],
      ),
    );
  }
}
