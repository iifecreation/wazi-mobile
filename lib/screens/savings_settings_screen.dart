import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SavingsSettingsScreen extends StatefulWidget {
  const SavingsSettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SavingsSettingsScreen> createState() => _SavingsSettingsScreenState();
}

class _SavingsSettingsScreenState extends State<SavingsSettingsScreen> {
  bool _autoSave = true;
  bool _spareChange = false;
  bool _lockedSavings = false;

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
                        'Savings Settings',
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
                    Text(
                      'Automation',
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
                          _SavingsToggleRow(
                            icon: Icons.autorenew_rounded,
                            title: 'Auto-Save',
                            subtitle: 'Automatically transfer money to savings based on your rules',
                            value: _autoSave,
                            onChanged: (val) => setState(() => _autoSave = val),
                          ),
                          _SavingsToggleRow(
                            icon: Icons.monetization_on_rounded,
                            title: 'Save Spare Change',
                            subtitle: 'Round up your transactions and save the difference',
                            value: _spareChange,
                            isLast: true,
                            onChanged: (val) => setState(() => _spareChange = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Security & Discipline',
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
                          _SavingsToggleRow(
                            icon: Icons.lock_clock_rounded,
                            title: 'Strict Lock',
                            subtitle: 'Prevent withdrawal from your savings until the target date is reached',
                            value: _lockedSavings,
                            isLast: true,
                            onChanged: (val) => setState(() => _lockedSavings = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Interest Preferences',
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
                          _SavingsActionRow(
                            icon: Icons.account_balance_rounded,
                            title: 'Interest Payout',
                            subtitle: 'Currently set to: Reinvest to Savings',
                            isLast: true,
                            onTap: () {},
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

class _SavingsActionRow extends StatelessWidget {
  const _SavingsActionRow({
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

class _SavingsToggleRow extends StatelessWidget {
  const _SavingsToggleRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
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
                    style: WaziText.inter(size: 12, color: Colors.white54),
                  ),
                ]
              ],
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
