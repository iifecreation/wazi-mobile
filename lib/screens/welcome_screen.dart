import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 42),
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 0,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [WaziColors.gold, WaziColors.goldDark]),
                ),
                alignment: Alignment.center,
                child: Text('w', style: WaziText.grotesk(size: 30, weight: FontWeight.w700, color: WaziColors.bg)),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Money that\nlistens.',
                  style: WaziText.grotesk(size: 44, weight: FontWeight.w600, letterSpacing: -1.5, height: 1.02),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 310),
                  child: Text(
                    'Send dollars home, pay for anything, check where your money went — by speaking. Naira and USD, one voice.',
                    style: WaziText.inter(size: 16, color: WaziColors.textAt(.6)),
                  ),
                ),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => appState.go(AppScreen.auth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WaziColors.gold,
                      foregroundColor: WaziColors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text('Create account', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => appState.go(AppScreen.login),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: WaziColors.textAt(.2)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text('I already have an account', style: WaziText.grotesk(size: 16, weight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    'Wazi processes your voice to understand requests and to recognise you. Recordings stay on your device unless you ask us to improve accuracy. Voice never authorises money on its own.',
                    style: WaziText.inter(size: 11.5, height: 1.5, color: WaziColors.textAt(.38)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
