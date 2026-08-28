import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SendMoneyScreen extends StatelessWidget {
  const SendMoneyScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => appState.go(AppScreen.services),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Send Money', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOptionCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'To Wazi Account',
                      subtitle: 'Free and instant transfer to any Wazi user',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      icon: Icons.account_balance_rounded,
                      title: 'To Bank Account',
                      subtitle: 'Send money to any local bank account',
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),
                    Text('Recent Beneficiaries', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    _buildBeneficiary(name: 'Sarah Jenkins', bank: 'Wazi Account', initials: 'SJ', color: Colors.blue),
                    _buildBeneficiary(name: 'Michael Doe', bank: 'Chase Bank', initials: 'MD', color: Colors.orange),
                    _buildBeneficiary(name: 'Mom', bank: 'Bank of America', initials: 'M', color: Colors.purple),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: WaziColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: WaziColors.gold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: WaziColors.textAt(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiary({required String name, required String bank, required String initials, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: color)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: WaziText.inter(size: 16, weight: FontWeight.w500, color: Colors.white)),
                const SizedBox(height: 4),
                Text(bank, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
