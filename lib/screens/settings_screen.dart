import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pill_toggle.dart';

const _langs = ['English', 'Pidgin', 'Yoruba', 'Igbo', 'Hausa', 'Swahili', 'French'];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.home),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 6),
                Text('Settings', style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
              ],
            ),
            const SizedBox(height: 28),
            _sectionLabel('VOICE & AI'),
            const SizedBox(height: 10),
            _Card(children: [
              _ToggleRow(
                title: 'Speak responses aloud',
                subtitle: 'Wazi replies with voice, not just text',
                value: appState.speak,
                onTap: appState.toggleSpeak,
              ),
              _ToggleRow(
                title: 'Ask before sensitive info',
                subtitle: "Check I'm private before saying balances",
                value: appState.ask,
                onTap: appState.toggleAsk,
              ),
              _ToggleRow(
                title: 'Earpiece connected',
                subtitle: 'Demo toggle — skips the privacy check',
                value: appState.head,
                onTap: appState.toggleHead,
              ),
              _NavRow(
                title: 'Re-record voiceprint',
                trailing: appState.enrolling ? 'Listening…' : (appState.enrolled ? 'Saved just now →' : 'Tap to record →'),
                trailingColor: WaziColors.teal,
                onTap: appState.enrolling ? () {} : appState.startEnroll,
                isLast: true,
              ),
            ]),
            const SizedBox(height: 26),
            _sectionLabel('SECURITY'),
            const SizedBox(height: 10),
            _Card(children: [
              _NavRow(title: 'Change PIN', trailing: '→', trailingColor: WaziColors.textAt(.4), onTap: appState.openPin),
              _ToggleRow(
                title: 'Face ID for large transfers',
                value: appState.face,
                onTap: appState.toggleFace,
                isLast: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily voice-transfer limit', style: WaziText.inter(size: 15)),
                        Text(
                          appState.regStatus?.limits.dailyLimitFormatted ?? '···',
                          style: WaziText.grotesk(size: 15, weight: FontWeight.w500, color: WaziColors.gold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      appState.regStatus != null
                          ? 'Tier ${appState.regStatus!.tier}${appState.regStatus!.limits.maxBalanceFormatted != null ? ' · balance up to ${appState.regStatus!.limits.maxBalanceFormatted}' : ' · no balance cap'}. Resets daily.'
                          : 'Sign in to see your tier limit.',
                      style: WaziText.inter(size: 12, color: WaziColors.textAt(.4)),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 26),
            _sectionLabel('PREFERENCES'),
            const SizedBox(height: 10),
            _Card(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voice language', style: WaziText.inter(size: 15)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: _langs.map((l) {
                        final active = appState.lang == l;
                        return GestureDetector(
                          onTap: () => appState.pickLang(l),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: active ? WaziColors.tealAt(.14) : Colors.transparent,
                              border: Border.all(color: active ? WaziColors.tealAt(.5) : WaziColors.textAt(.12)),
                            ),
                            child: Text(l, style: WaziText.inter(size: 12.5, color: active ? WaziColors.teal : WaziColors.textAt(.7))),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              _NavRow(title: 'Notifications', trailing: 'All transfers →', trailingColor: WaziColors.textAt(.45), onTap: appState.openNotif, isLast: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String s) => Text(s, style: WaziText.inter(size: 11.5, color: WaziColors.textAt(.4), letterSpacing: 1.6));
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: WaziColors.card,
        border: Border.all(color: WaziColors.textAt(.07)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, this.subtitle, required this.value, required this.onTap, this.isLast = false});

  final String title;
  final String? subtitle;
  final bool value;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.06))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: WaziText.inter(size: 15)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: WaziText.inter(size: 12.5, color: WaziColors.textAt(.45))),
                  ],
                ],
              ),
            ),
            PillToggle(value: value),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.title, required this.trailing, required this.trailingColor, required this.onTap, this.isLast = false});

  final String title;
  final String trailing;
  final Color trailingColor;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.06))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: WaziText.inter(size: 15)),
            Text(trailing, style: WaziText.inter(size: 12.5, color: trailingColor)),
          ],
        ),
      ),
    );
  }
}
