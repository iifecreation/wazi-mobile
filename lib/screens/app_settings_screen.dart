import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key, required this.appState});

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
                    onPressed: () => appState.go(AppScreen.settings),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Balance the back button for centering
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Group 1
                    _SettingsGroup(
                      children: [
                        _SettingsRow(icon: Icons.person_outline_rounded, title: 'My Profile', onTap: () => appState.go(AppScreen.myProfile)),
                        _SettingsRow(icon: Icons.lock_outline_rounded, title: 'Payment Settings', onTap: () => appState.go(AppScreen.paymentSettings)),
                        _SettingsRow(icon: Icons.vpn_key_outlined, title: 'Login Settings', onTap: () => appState.go(AppScreen.loginSettings)),
                        _SettingsRow(icon: Icons.account_balance_wallet_outlined, title: 'Savings Settings', isLast: true, onTap: () => appState.go(AppScreen.savingsSettings)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Group 2
                    _SettingsGroup(
                      children: [
                        _SettingsRow(icon: Icons.home_outlined, title: 'Homepage Settings', hasRedDot: true, onTap: () => appState.go(AppScreen.homepageSettings)),
                        _SettingsRow(
                          icon: Icons.help_outline_rounded, 
                          title: 'Security Questions', 
                          trailingText: 'Not Set',
                          trailingColor: WaziColors.gold,
                          onTap: () => appState.go(AppScreen.securityQuestions),
                        ),
                        _SettingsRow(icon: Icons.message_outlined, title: 'SMS Alert Settings', onTap: () => appState.go(AppScreen.smsAlertSettings)),
                        _SettingsRow(icon: Icons.content_paste_rounded, title: 'Access to Clipboard', onTap: () => appState.go(AppScreen.clipboardSettings)),
                        _SettingsRow(icon: Icons.brightness_medium_outlined, title: 'Themes', hasRedDot: true, isLast: true, onTap: () => appState.go(AppScreen.themesSettings)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Group 3
                    _SettingsGroup(
                      children: [
                        _SettingsRow(icon: Icons.security_rounded, title: 'Security Center', onTap: () => appState.go(AppScreen.securityCenter)),
                        _SettingsRow(icon: Icons.edit_note_rounded, title: 'Feedback and Suggestions', isLast: true, onTap: () => appState.go(AppScreen.feedback)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Group 4
                    _SettingsGroup(
                      children: [
                        _SettingsRow(icon: Icons.power_settings_new_rounded, title: 'close account', isLast: true, onTap: () => appState.go(AppScreen.closeAccount)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Group 5
                    _SettingsGroup(
                      children: [
                        _SettingsRow(icon: Icons.info_outline_rounded, title: 'about', isLast: true, onTap: () => appState.go(AppScreen.aboutSettings)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: appState.signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Sign Out', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingColor,
    this.hasRedDot = false,
    this.isLast = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final Color? trailingColor;
  final bool hasRedDot;
  final bool isLast;
  final VoidCallback? onTap;

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
            Icon(icon, color: Colors.greenAccent, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: WaziText.inter(size: 15, weight: FontWeight.w400, color: Colors.white),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: WaziText.inter(size: 13, color: trailingColor ?? WaziColors.textAt(0.5)),
              ),
              const SizedBox(width: 8),
            ],
            if (hasRedDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded, color: WaziColors.textAt(0.3), size: 20),
          ],
        ),
      ),
    );
  }
}
