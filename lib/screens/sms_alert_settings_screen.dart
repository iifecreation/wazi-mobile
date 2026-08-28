import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SmsAlertSettingsScreen extends StatefulWidget {
  const SmsAlertSettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SmsAlertSettingsScreen> createState() => _SmsAlertSettingsScreenState();
}

class _SmsAlertSettingsScreenState extends State<SmsAlertSettingsScreen> {
  bool _creditAlerts = true;
  bool _debitAlerts = true;
  bool _loginAlerts = false;

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
                        'SMS Alert Settings',
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
                    // Warning section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: WaziColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WaziColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 20, color: WaziColors.gold),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Standard SMS charges may apply depending on your network provider. Push notifications inside the app are always free.',
                              style: WaziText.inter(size: 13, color: Colors.white70, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Transaction Alerts',
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
                          _SmsToggleRow(
                            icon: Icons.south_west_rounded,
                            iconColor: Colors.greenAccent,
                            title: 'Credit Alerts',
                            subtitle: 'Receive an SMS when money enters your account',
                            value: _creditAlerts,
                            onChanged: (val) => setState(() => _creditAlerts = val),
                          ),
                          _SmsToggleRow(
                            icon: Icons.north_east_rounded,
                            iconColor: Colors.redAccent,
                            title: 'Debit Alerts',
                            subtitle: 'Receive an SMS when money leaves your account',
                            value: _debitAlerts,
                            isLast: true,
                            onChanged: (val) => setState(() => _debitAlerts = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Security Alerts',
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
                          _SmsToggleRow(
                            icon: Icons.login_rounded,
                            iconColor: Colors.blueAccent,
                            title: 'New Login Alerts',
                            subtitle: 'Receive an SMS when your account is logged into from a new device',
                            value: _loginAlerts,
                            isLast: true,
                            onChanged: (val) => setState(() => _loginAlerts = val),
                          ),
                        ],
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
}

class _SmsToggleRow extends StatelessWidget {
  const _SmsToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: WaziText.inter(size: 15, weight: FontWeight.w500, color: Colors.white),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: WaziText.inter(size: 12, color: Colors.white54, height: 1.4),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 16),
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
