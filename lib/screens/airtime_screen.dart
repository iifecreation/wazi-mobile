import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AirtimeScreen extends StatelessWidget {
  const AirtimeScreen({super.key, required this.appState});

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
                  Text('Airtime & Data', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs for Airtime / Data
                    Row(
                      children: [
                        _buildTab(title: 'Airtime', active: true),
                        const SizedBox(width: 12),
                        _buildTab(title: 'Data', active: false),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Phone Number', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: TextField(
                        style: WaziText.inter(size: 16, color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter phone number',
                          hintStyle: WaziText.inter(size: 16, color: WaziColors.textAt(0.3)),
                          icon: Icon(Icons.contact_phone_outlined, color: WaziColors.textAt(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Select Amount', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _buildAmount(amount: '\$5'),
                        _buildAmount(amount: '\$10', active: true),
                        _buildAmount(amount: '\$20'),
                        _buildAmount(amount: '\$50'),
                        _buildAmount(amount: '\$100'),
                        _buildAmount(amount: '\$200'),
                      ],
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WaziColors.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Continue', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
                      ),
                    ),
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
          color: active ? WaziColors.gold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? WaziColors.gold : Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            title,
            style: WaziText.inter(
              size: 14,
              weight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? WaziColors.gold : WaziColors.textAt(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmount({required String amount, bool active = false}) {
    return Container(
      decoration: BoxDecoration(
        color: active ? WaziColors.gold : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? WaziColors.gold : Colors.white.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(
          amount,
          style: WaziText.inter(
            size: 16,
            weight: FontWeight.w600,
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
