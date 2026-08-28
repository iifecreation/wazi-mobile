import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class WaziBottomNav extends StatelessWidget {
  const WaziBottomNav({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    // Determine active tab based on current screen
    final isBank = appState.screen == AppScreen.dashboard;
    final isCards = appState.screen == AppScreen.cards;
    final isFinance = appState.screen == AppScreen.finance;
    final isSettings = appState.screen == AppScreen.settings;

    return Container(
      height: 68,
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: WaziColors.bg.withValues(alpha: .94),
        border: Border(top: BorderSide(color: WaziColors.textAt(.07))),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_outlined, 
            label: 'Home', 
            color: isBank ? WaziColors.text : WaziColors.textAt(.45), 
            onTap: () {
              appState.go(AppScreen.dashboard);
            },
          ),
          _NavItem(
            icon: Icons.credit_card_rounded, 
            label: 'Cards', 
            color: isCards ? WaziColors.text : WaziColors.textAt(.45), 
            onTap: () {
              appState.go(AppScreen.cards);
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => appState.go(AppScreen.home),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.teal),
                    child: const Icon(Icons.mic_rounded, size: 16, color: WaziColors.bg),
                  ),
                  const SizedBox(height: 5),
                  Text('Voice', style: WaziText.inter(size: 10.5, color: WaziColors.teal)),
                ],
              ),
            ),
          ),
          _NavItem(
            icon: Icons.account_balance_wallet_rounded, 
            label: 'Finance', 
            color: isFinance ? WaziColors.text : WaziColors.textAt(.45), 
            onTap: () => appState.go(AppScreen.finance),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded, 
            label: 'Me', 
            color: isSettings ? WaziColors.text : WaziColors.textAt(.45), 
            onTap: () => appState.go(AppScreen.settings),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(label, style: WaziText.inter(size: 10.5, color: color)),
          ],
        ),
      ),
    );
  }
}
