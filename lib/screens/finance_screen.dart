import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/bottom_nav.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: WaziBottomNav(appState: appState),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => appState.go(AppScreen.dashboard),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Finance', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text('Finance content coming soon', style: WaziText.inter(size: 14, color: WaziColors.textAt(.45))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
