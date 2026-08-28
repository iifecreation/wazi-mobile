import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class OJuniorScreen extends StatelessWidget {
  const OJuniorScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => appState.go(AppScreen.settings), // Assuming accessed from Me tab
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Wazi Junior',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Balance the back button
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Illustration / Icon
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.child_care_rounded, size: 100, color: Colors.greenAccent),
                          Positioned(
                            bottom: 30,
                            right: 30,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: WaziColors.bg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.star_rounded, color: WaziColors.gold, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Financial Freedom\nfor Your Kids',
                      style: WaziText.inter(size: 24, weight: FontWeight.w800, color: Colors.white, height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create a sub-account for your children to teach them how to save, spend, and manage money safely.',
                      style: WaziText.inter(size: 15, color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Features list
                    _FeatureRow(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Set Allowances',
                      description: 'Automate weekly or monthly pocket money transfers.',
                    ),
                    const SizedBox(height: 24),
                    _FeatureRow(
                      icon: Icons.track_changes_rounded,
                      title: 'Monitor Spending',
                      description: 'Get real-time alerts whenever they make a purchase.',
                    ),
                    const SizedBox(height: 24),
                    _FeatureRow(
                      icon: Icons.security_rounded,
                      title: 'Full Parental Control',
                      description: 'Lock their card or set strict spending limits instantly.',
                    ),
                    
                    const SizedBox(height: 48),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: WaziColors.bg,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text('Create Junior Account', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
                      ),
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
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.greenAccent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: WaziText.inter(size: 13, color: Colors.white54, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
