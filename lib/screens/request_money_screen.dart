import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class RequestMoneyScreen extends StatelessWidget {
  const RequestMoneyScreen({super.key, required this.appState});

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
                  Text('Request Money', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Icon(Icons.qr_code_2_rounded, size: 200, color: Colors.black.withValues(alpha: 0.8)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('@wazi_user', style: WaziText.grotesk(size: 24, weight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Scan to pay or send via Wazi tag', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.5))),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAction(icon: Icons.share_rounded, label: 'Share Link'),
                        const SizedBox(width: 32),
                        _buildAction(icon: Icons.copy_rounded, label: 'Copy Tag'),
                        const SizedBox(width: 32),
                        _buildAction(icon: Icons.download_rounded, label: 'Save Image'),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Recent Requests', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentRequest(name: 'Michael Doe', status: 'Pending', amount: '\$45.00'),
                    _buildRecentRequest(name: 'Sarah Smith', status: 'Paid', amount: '\$120.00'),
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

  Widget _buildAction({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.7), weight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRecentRequest({required String name, required String status, required String amount}) {
    final isPaid = status == 'Paid';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(name[0], style: WaziText.grotesk(size: 18, weight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: WaziText.inter(size: 16, weight: FontWeight.w500, color: Colors.white)),
                const SizedBox(height: 4),
                Text(status, style: WaziText.inter(size: 12, color: isPaid ? Colors.green : Colors.orange)),
              ],
            ),
          ),
          Text(amount, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
