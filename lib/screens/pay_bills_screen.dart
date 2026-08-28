import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class PayBillsScreen extends StatelessWidget {
  const PayBillsScreen({super.key, required this.appState});

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
                  Text('Pay Bills', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select a Biller Category', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildCategoryCard(icon: Icons.bolt_rounded, label: 'Electricity', color: Colors.orange, onTap: () => appState.go(AppScreen.electricity)),
                        _buildCategoryCard(icon: Icons.tv_rounded, label: 'Cable TV', color: Colors.blue, onTap: () => appState.go(AppScreen.cableTv)),
                        _buildCategoryCard(icon: Icons.wifi_rounded, label: 'Internet', color: Colors.green, onTap: () {}),
                        _buildCategoryCard(icon: Icons.water_drop_rounded, label: 'Water', color: Colors.cyan, onTap: () {}),
                        _buildCategoryCard(icon: Icons.school_rounded, label: 'Education', color: Colors.purple, onTap: () {}),
                        _buildCategoryCard(icon: Icons.account_balance_rounded, label: 'Taxes', color: Colors.redAccent, onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Recent Bills', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    _buildRecentBill(title: 'Ikeja Electric', amount: '\$45.00', date: 'Aug 12, 2026', icon: Icons.bolt_rounded, color: Colors.orange),
                    _buildRecentBill(title: 'DSTV Premium', amount: '\$24.99', date: 'Jul 28, 2026', icon: Icons.tv_rounded, color: Colors.blue),
                    _buildRecentBill(title: 'Spectranet', amount: '\$60.00', date: 'Jul 15, 2026', icon: Icons.wifi_rounded, color: Colors.green),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(label, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBill({required String title, required String amount, required String date, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w500, color: Colors.white)),
                const SizedBox(height: 4),
                Text(date, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
              ],
            ),
          ),
          Text(amount, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
