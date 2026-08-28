import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mic_button.dart';

class VoiceWelcomeScreen extends StatefulWidget {
  const VoiceWelcomeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<VoiceWelcomeScreen> createState() => _VoiceWelcomeScreenState();
}

class _VoiceWelcomeScreenState extends State<VoiceWelcomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _sensitiveInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kick off the conversation with an empty transcript to get the AI's greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.runOnboardingTranscript('');
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
                        onPressed: () => widget.appState.go(AppScreen.welcome),
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
                    itemCount: widget.appState.onboardingTurns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, i) {
                      final t = widget.appState.onboardingTurns[i];
                      // If it's an empty transcript from the kick-off, don't show the user bubble
                      if (t.role == ChatRole.user && t.text.trim().isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final isLatestAi = (t.role == ChatRole.ai) && (i == widget.appState.onboardingTurns.length - 1);
                      return ChatBubble(turn: t, showSpeaking: isLatestAi && t.speaking);
                    },
                  ),
                ),
              ],
            ),
            
            // Sensitive Data Overlay
            if (widget.appState.sheet == SheetType.bvn_input || widget.appState.sheet == SheetType.nin_input)
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
                            widget.appState.sheet == SheetType.bvn_input ? 'Enter your BVN' : 'Enter your NIN',
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
                              keyboardType: TextInputType.number,
                              style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: widget.appState.sheet == SheetType.bvn_input ? '11-digit BVN' : '11-digit NIN',
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
                                
                                if (widget.appState.sheet == SheetType.bvn_input) {
                                  widget.appState.submitOnboardingBvn(text);
                                } else {
                                  widget.appState.submitOnboardingNin(text);
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
