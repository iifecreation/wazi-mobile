import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mic_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final showChips = appState.turns.isEmpty && !appState.listening;
    return SafeArea(
      child: Stack(
        children: [
          // balance pill
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => appState.go(AppScreen.insights),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: WaziColors.card.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: WaziColors.textAt(.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.gold)),
                      const SizedBox(width: 9),
                      Text(appState.balanceLabel, style: WaziText.grotesk(size: 14, weight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // left icon rail
          Positioned(
            left: 16,
            top: 62,
            child: Column(
              children: [
                _RailButton(icon: Icons.keyboard_alt_outlined, onTap: appState.toTyping),
                const SizedBox(height: 12),
                _RailButton(icon: Icons.settings_outlined, onTap: () => appState.go(AppScreen.settings)),
                const SizedBox(height: 12),
                _RailButton(icon: Icons.notifications_none_rounded, onTap: appState.openNotif, badge: true),
                const SizedBox(height: 12),
                _RailButton(icon: Icons.headset_mic_outlined, onTap: appState.openSupport),
                const SizedBox(height: 12),
                _RailButton(
                  icon: appState.speak ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  onTap: appState.toggleSpeak,
                  active: appState.speak,
                ),
              ],
            ),
          ),

          // Main content flow: transcript takes whatever space is left
          // above the chips/mic/hint block, which sizes to its own content
          // (including a 2-row-wrapped chip layout on narrower text scales)
          // — no fixed-height guess for the transcript that the block could
          // outgrow and overlap.
          Positioned(
            left: 0,
            right: 0,
            top: 120,
            bottom: 20,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 78, right: 20),
                    child: appState.turns.isEmpty
                        ? const _EmptyTranscript()
                        : ListView.separated(
                            reverse: false,
                            padding: EdgeInsets.zero,
                            itemCount: appState.turns.length,
                            separatorBuilder: (context, i) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final t = appState.turns[i];
                              return ChatBubble(turn: t, showSpeaking: i == appState.turns.length - 1);
                            },
                          ),
                  ),
                ),
                if (showChips)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(label: '"Send 2,000 naira to Tunde"', onTap: appState.askSend),
                        _Chip(label: '"What\'s my balance?"', onTap: appState.askBalance),
                        _Chip(label: '"Where did my money go?"', onTap: appState.askSpend),
                        _Chip(label: '"Scan this"', onTap: appState.askScan),
                        _Chip(label: '"Pay school fees at Kings College"', onTap: appState.askPayFees),
                        _Chip(label: '"I need 1,000 naira from Mum"', onTap: appState.askRequestMoney),
                      ],
                    ),
                  ),
                MicButton(listening: appState.listening, soundLevel: appState.soundLevel, onTap: appState.onMic),
                const SizedBox(height: 12),
                Text(
                  appState.processing 
                      ? 'PROCESSING...' 
                      : appState.isSpeaking 
                          ? 'SPEAKING...' 
                          : appState.listening 
                              ? 'LISTENING...'
                              : 'TAP TO SPEAK',
                  style: WaziText.inter(
                    size: 12.5, 
                    letterSpacing: 2.0, 
                    color: appState.listening ? WaziColors.teal : WaziColors.textAt(.45)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.icon, required this.onTap, this.badge = false, this.active = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? WaziColors.goldAt(.16) : WaziColors.card.withValues(alpha: .85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: active ? WaziColors.goldAt(.45) : WaziColors.textAt(.1)),
            ),
            child: Icon(icon, size: 20, color: active ? WaziColors.gold : WaziColors.textAt(.75)),
          ),
          if (badge)
            Positioned(
              top: 9,
              right: 9,
              child: Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.gold)),
            ),
        ],
      ),
    );
  }
}

class _EmptyTranscript extends StatelessWidget {
  const _EmptyTranscript();

  @override
  Widget build(BuildContext context) {
    final heights = [10.0, 22.0, 34.0, 16.0, 26.0, 8.0];
    return Opacity(
      opacity: .5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: heights
                  .map((h) => Container(width: 3, height: h, margin: const EdgeInsets.symmetric(horizontal: 2.5), color: WaziColors.textAt(.5)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              'Ask for a transfer, a balance, or where your money went.',
              textAlign: TextAlign.center,
              style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: WaziColors.textAt(.14)),
        ),
        child: Text(label, style: WaziText.inter(size: 12.5, color: WaziColors.textAt(.8))),
      ),
    );
  }
}
