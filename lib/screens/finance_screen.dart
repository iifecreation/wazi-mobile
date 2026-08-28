import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
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
                  Text('Finance', style: WaziText.grotesk(size: 24, weight: FontWeight.w600, color: Colors.white)),
                  const Spacer(),
                  Icon(Icons.pie_chart_outline_rounded, color: Colors.white.withValues(alpha: 0.5)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs
                    Row(
                      children: [
                        _buildTab(title: 'Analytics', active: true),
                        const SizedBox(width: 12),
                        _buildTab(title: 'Wealth', active: false),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Monthly Summary
                    Text('Monthly Summary', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryCard(title: 'Income', amount: '\$4,250.00', icon: Icons.arrow_downward_rounded, color: WaziColors.teal),
                        const SizedBox(width: 16),
                        _buildSummaryCard(title: 'Spent', amount: '\$2,140.50', icon: Icons.arrow_upward_rounded, color: Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Top Categories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Top Categories', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                        Text('See All', style: WaziText.inter(size: 12, weight: FontWeight.w500, color: WaziColors.gold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryRow(title: 'Food & Dining', amount: '\$450.00', percent: 0.7, color: Colors.orange),
                    _buildCategoryRow(title: 'Transportation', amount: '\$230.00', percent: 0.4, color: Colors.blue),
                    _buildCategoryRow(title: 'Shopping', amount: '\$150.00', percent: 0.25, color: Colors.purple),
                    const SizedBox(height: 32),
                    
                    // Goals
                    Text('Savings Goals', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    _buildGoalCard(title: 'New Car', current: '\$5,000', target: '\$20,000', progress: 0.25),
                    const SizedBox(height: 12),
                    _buildGoalCard(title: 'Vacation', current: '\$1,200', target: '\$3,000', progress: 0.4),
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

  Widget _buildTab({required String title, required bool active}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: WaziText.inter(
              size: 14,
              weight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? Colors.white : WaziColors.textAt(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String amount, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 12),
            Text(title, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
            const SizedBox(height: 4),
            Text(amount, style: WaziText.grotesk(size: 18, weight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow({required String title, required String amount, required double percent, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.category_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
                    Text(amount, style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({required String title, required String current, required String target, required double progress}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
              Text('$current / $target', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(WaziColors.gold),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
