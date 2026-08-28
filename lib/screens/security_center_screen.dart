import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  bool _biometricLogin = true;
  bool _biometricPayment = false;
  bool _hideBalance = true;

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
                    onPressed: () => widget.appState.go(AppScreen.appSettings),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Security Center',
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Security
                    Text(
                      'Device Security',
                      style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SecurityActionRow(
                            icon: Icons.devices_rounded,
                            title: 'Manage Devices',
                            subtitle: 'View and manage devices logged into your account',
                            onTap: () {},
                          ),
                          _SecurityActionRow(
                            icon: Icons.phonelink_erase_rounded,
                            title: 'Remote Logout',
                            subtitle: 'Sign out of all other devices',
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Authentication
                    Text(
                      'Authentication',
                      style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SecurityActionRow(
                            icon: Icons.password_rounded,
                            title: 'Change Password',
                            onTap: () {},
                          ),
                          _SecurityActionRow(
                            icon: Icons.pin_rounded,
                            title: 'Change Payment PIN',
                            onTap: () {},
                          ),
                          _SecurityToggleRow(
                            icon: Icons.fingerprint_rounded,
                            title: 'Biometric Login',
                            value: _biometricLogin,
                            onChanged: (val) => setState(() => _biometricLogin = val),
                          ),
                          _SecurityToggleRow(
                            icon: Icons.fingerprint_rounded,
                            title: 'Biometric Payment',
                            value: _biometricPayment,
                            isLast: true,
                            onChanged: (val) => setState(() => _biometricPayment = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Privacy
                    Text(
                      'Privacy',
                      style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SecurityToggleRow(
                            icon: Icons.visibility_off_rounded,
                            title: 'Hide Balance by Default',
                            value: _hideBalance,
                            isLast: true,
                            onChanged: (val) => setState(() => _hideBalance = val),
                          ),
                        ],
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

class _SecurityActionRow extends StatelessWidget {
  const _SecurityActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isLast = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
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
            Icon(icon, color: Colors.greenAccent, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: WaziText.inter(size: 15, weight: FontWeight.w500, color: Colors.white),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: WaziText.inter(size: 12, color: Colors.white54),
                    ),
                  ]
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}

class _SecurityToggleRow extends StatelessWidget {
  const _SecurityToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              style: WaziText.inter(size: 15, weight: FontWeight.w500, color: Colors.white),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.greenAccent,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white54,
          ),
        ],
      ),
    );
  }
}
