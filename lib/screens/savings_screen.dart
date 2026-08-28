import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key, required this.appState});

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
                  Text('Savings Goals', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: WaziColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: WaziColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Total Savings', style: WaziText.inter(size: 14, color: WaziColors.gold.withValues(alpha: 0.8))),
                          const SizedBox(height: 8),
                          Text('\$8,450.00', style: WaziText.grotesk(size: 32, weight: FontWeight.w600, color: WaziColors.gold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Interest Earned: ', style: WaziText.inter(size: 12, color: Colors.white.withValues(alpha: 0.5))),
                              Text('+\$142.50', style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Goals', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('+ New', style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGoalCard(
                      title: 'Emergency Fund',
                      current: '\$5,000.00',
                      target: '\$10,000.00',
                      progress: 0.5,
                      color: Colors.blue,
                      icon: Icons.shield_rounded,
                    ),
                    _buildGoalCard(
                      title: 'Vacation',
                      current: '\$2,450.00',
                      target: '\$3,000.00',
                      progress: 0.81,
                      color: Colors.orange,
                      icon: Icons.flight_takeoff_rounded,
                    ),
                    _buildGoalCard(
                      title: 'New Laptop',
                      current: '\$1,000.00',
                      target: '\$2,500.00',
                      progress: 0.4,
                      color: Colors.purple,
                      icon: Icons.laptop_mac_rounded,
                    ),
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

  Widget _buildGoalCard({
    required String title,
    required String current,
    required String target,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
              ),
              Text('${(progress * 100).toInt()}%', style: WaziText.inter(size: 14, weight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(current, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
              Text('of $target', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
            ],
          ),
        ],
      ),
    );
  }
}
