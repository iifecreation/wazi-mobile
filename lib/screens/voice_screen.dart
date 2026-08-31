import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mic_button.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _sensitiveInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kick off the conversation with an empty transcript to get the AI's greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.appState.userId == null) {
        if (widget.appState.onboardingTurns.isEmpty) {
          widget.appState.runOnboardingTranscript('');
        }
      } else {
        if (widget.appState.turns.isEmpty) {
          widget.appState.run('');
        }
      }
    });
  }

  @override
  void dispose() {
    _sensitiveInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.appState.userId != null;
    final turns = isLoggedIn ? widget.appState.turns : widget.appState.onboardingTurns;

    // Auto-scroll when turns change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => widget.appState.go(isLoggedIn ? AppScreen.dashboard : AppScreen.welcome),
                        child: Text('Traditional', style: WaziText.inter(size: 15, color: WaziColors.teal, weight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                
                // Chat History
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                    itemCount: turns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, i) {
                      final t = turns[i];
                      // If it's an empty transcript from the kick-off, don't show the user bubble
                      if (t.role == ChatRole.user && t.text.trim().isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final isLatestAi = (t.role == ChatRole.ai) && (i == turns.length - 1);
                      return ChatBubble(turn: t, showSpeaking: isLatestAi && t.speaking);
                    },
                  ),
                ),
              ],
            ),
            
            // Sensitive Data Overlay — BVN, NIN, login password, and
            // transaction PIN all land here: typed on screen, never
            // spoken or sent as a voice transcript. See
            // app/dialogue/onboarding.py's module docstring for why.
            if (_sensitiveSheetTypes.contains(widget.appState.sheet))
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: WaziColors.bg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _sensitiveFieldTitle(widget.appState.sheet),
                            style: WaziText.grotesk(size: 20, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'For your privacy, please type it below rather than speaking it out loud.',
                            style: WaziText.inter(size: 14, color: WaziColors.textAt(.6)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: WaziColors.teal.withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _sensitiveInputController,
                              keyboardType: _sensitiveFieldIsNumeric(widget.appState.sheet) ? TextInputType.number : TextInputType.visiblePassword,
                              obscureText: _sensitiveFieldObscured(widget.appState.sheet),
                              style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: _sensitiveFieldHint(widget.appState.sheet),
                                hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0, color: WaziColors.textAt(.3)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final text = _sensitiveInputController.text.trim();
                                if (text.isEmpty) return;
                                switch (widget.appState.sheet) {
                                  case SheetType.bvn_input:
                                    widget.appState.submitOnboardingBvn(text);
                                    break;
                                  case SheetType.nin_input:
                                    widget.appState.submitOnboardingNin(text);
                                    break;
                                  case SheetType.password_input:
                                    widget.appState.submitOnboardingPassword(text);
                                    break;
                                  case SheetType.transaction_pin_input:
                                    widget.appState.submitOnboardingTransactionPin(text);
                                    break;
                                  default:
                                    break;
                                }
                                _sensitiveInputController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WaziColors.gold,
                                foregroundColor: WaziColors.bg,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 0,
                              ),
                              child: Text('Submit Securely', style: WaziText.inter(size: 15, weight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      
      // Bottom Mic Button overlay
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.appState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(widget.appState.error!, style: WaziText.inter(size: 12, color: Colors.red)),
            ),
          MicButton(
            listening: widget.appState.listening,
            soundLevel: widget.appState.soundLevel,
            onTap: widget.appState.toggleListening,
          ),
          const SizedBox(height: 12),
          Text(
            widget.appState.processing 
                ? 'PROCESSING...' 
                : widget.appState.isSpeaking 
                    ? 'SPEAKING...' 
                    : widget.appState.listening 
                        ? 'LISTENING...'
                        : 'TAP TO SPEAK',
            style: WaziText.inter(
              size: 12.5, 
              letterSpacing: 2.0, 
              color: widget.appState.listening ? WaziColors.teal : WaziColors.textAt(.45)
            ),
          ),
        ],
      ),
    );
  }
}

const _sensitiveSheetTypes = {
  SheetType.bvn_input,
  SheetType.nin_input,
  SheetType.password_input,
  SheetType.transaction_pin_input,
};

String _sensitiveFieldTitle(SheetType? sheet) {
  switch (sheet) {
    case SheetType.bvn_input:
      return 'Enter your BVN';
    case SheetType.nin_input:
      return 'Enter your NIN';
    case SheetType.password_input:
      return 'Set your login password';
    case SheetType.transaction_pin_input:
      return 'Set your transaction PIN';
    default:
      return '';
  }
}

String _sensitiveFieldHint(SheetType? sheet) {
  switch (sheet) {
    case SheetType.bvn_input:
      return '11-digit BVN';
    case SheetType.nin_input:
      return '11-digit NIN';
    case SheetType.password_input:
      return 'Password';
    case SheetType.transaction_pin_input:
      return '4-digit PIN';
    default:
      return '';
  }
}

bool _sensitiveFieldIsNumeric(SheetType? sheet) =>
    sheet == SheetType.bvn_input || sheet == SheetType.nin_input || sheet == SheetType.transaction_pin_input;

bool _sensitiveFieldObscured(SheetType? sheet) =>
    sheet == SheetType.password_input || sheet == SheetType.transaction_pin_input;
