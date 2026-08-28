import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.dashboard),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                Text('All Services', style: WaziText.grotesk(size: 24, weight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategory(
                    title: 'Transfers & Payments',
                    services: [
                      _ServiceItem(icon: Icons.arrow_upward_rounded, label: 'Send Money'),
                      _ServiceItem(icon: Icons.attach_money_rounded, label: 'International'),
                      _ServiceItem(icon: Icons.qr_code_scanner_rounded, label: 'Scan to Pay', iconColor: WaziColors.teal, onTap: () => appState.go(AppScreen.scan)),
                      _ServiceItem(icon: Icons.arrow_downward_rounded, label: 'Request Money'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildCategory(
                    title: 'Airtime & Utilities',
                    services: [
                      _ServiceItem(icon: Icons.receipt_long_rounded, label: 'Airtime & Data'),
                      _ServiceItem(icon: Icons.payment_rounded, label: 'Pay Bills'),
                      _ServiceItem(icon: Icons.bolt_rounded, label: 'Electricity'),
                      _ServiceItem(icon: Icons.tv_rounded, label: 'Cable TV'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildCategory(
                    title: 'Cards & Savings',
                    services: [
                      _ServiceItem(icon: Icons.credit_card_outlined, label: 'Virtual Cards'),
                      _ServiceItem(icon: Icons.track_changes_rounded, label: 'Savings Goals'),
                      _ServiceItem(icon: Icons.account_balance_rounded, label: 'Fixed Deposits'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildCategory(
                    title: 'Lifestyle',
                    services: [
                      _ServiceItem(icon: Icons.confirmation_number_outlined, label: 'Event Tickets'),
                      _ServiceItem(icon: Icons.flight_outlined, label: 'Book Flights'),
                      _ServiceItem(icon: Icons.hotel_outlined, label: 'Hotels'),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory({required String title, required List<_ServiceItem> services}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
          children: services.map((s) => _buildServiceIcon(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceIcon(_ServiceItem item) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: item.onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.label} coming soon!'))),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.iconColor.withValues(alpha: 0.15),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 22),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                style: WaziText.inter(size: 11, color: Colors.white, weight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  _ServiceItem({
    required this.icon,
    required this.label,
    this.iconColor = WaziColors.gold,
    this.onTap,
  });
}
