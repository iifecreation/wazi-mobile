import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key, required this.appState});

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
                    onPressed: () => appState.go(AppScreen.appSettings),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'About Wazi',
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo and Version
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'W',
                          style: WaziText.grotesk(size: 40, color: WaziColors.bg, weight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Wazi Mobile',
                      style: WaziText.inter(size: 20, weight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0 (Build 42)',
                      style: WaziText.inter(size: 13, color: Colors.white54),
                    ),
                    const SizedBox(height: 40),
                    
                    // Action Links
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _AboutActionRow(
                            title: 'Rate us on the App Store',
                            icon: Icons.star_rounded,
                            onTap: () {},
                          ),
                          _AboutActionRow(
                            title: 'Like us on Facebook',
                            icon: Icons.thumb_up_rounded,
                            onTap: () {},
                          ),
                          _AboutActionRow(
                            title: 'Follow us on Twitter/X',
                            icon: Icons.chat_bubble_rounded,
                            onTap: () {},
                          ),
                          _AboutActionRow(
                            title: 'Follow us on Instagram',
                            icon: Icons.camera_alt_rounded,
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Legal Links
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _AboutActionRow(
                            title: 'Terms of Service',
                            icon: Icons.description_rounded,
                            onTap: () {},
                          ),
                          _AboutActionRow(
                            title: 'Privacy Policy',
                            icon: Icons.privacy_tip_rounded,
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    Text(
                      '© 2026 Wazi Financial Technologies.\nAll rights reserved.',
                      style: WaziText.inter(size: 12, color: Colors.white30, height: 1.5),
                      textAlign: TextAlign.center,
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
}

class _AboutActionRow extends StatelessWidget {
  const _AboutActionRow({
    required this.title,
    required this.icon,
    this.isLast = false,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: WaziText.inter(size: 15, weight: FontWeight.w500, color: Colors.white),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}
