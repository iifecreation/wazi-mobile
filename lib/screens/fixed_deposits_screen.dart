import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class FixedDepositsScreen extends StatelessWidget {
  const FixedDepositsScreen({super.key, required this.appState});

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
                  Text('Fixed Deposits', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A2D34), Color(0xFF141518)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Total Fixed Deposits', style: WaziText.inter(size: 14, color: Colors.white.withValues(alpha: 0.7))),
                          const SizedBox(height: 8),
                          Text('\$15,000.00', style: WaziText.grotesk(size: 32, weight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Expected Returns: ', style: WaziText.inter(size: 12, color: Colors.white.withValues(alpha: 0.5))),
                              Text('+\$1,250.00', style: WaziText.inter(size: 12, weight: FontWeight.w600, color: WaziColors.gold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: Text('Create New Deposit', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WaziColors.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text('Active Plans', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    _buildPlanCard(
                      name: '1 Year Lock',
                      amount: '\$10,000.00',
                      rate: '8.5% p.a',
                      maturity: 'Aug 2027',
                    ),
                    _buildPlanCard(
                      name: '6 Months Flex',
                      amount: '\$5,000.00',
                      rate: '5.0% p.a',
                      maturity: 'Feb 2027',
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

  Widget _buildPlanCard({
    required String name,
    required String amount,
    required String rate,
    required String maturity,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: WaziColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(rate, style: WaziText.inter(size: 12, weight: FontWeight.w600, color: WaziColors.gold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Principal', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                  const SizedBox(height: 4),
                  Text(amount, style: WaziText.inter(size: 18, weight: FontWeight.w600, color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Maturity', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                  const SizedBox(height: 4),
                  Text(maturity, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
