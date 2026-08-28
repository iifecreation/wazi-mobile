import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ThemesSettingsScreen extends StatefulWidget {
  const ThemesSettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ThemesSettingsScreen> createState() => _ThemesSettingsScreenState();
}

class _ThemesSettingsScreenState extends State<ThemesSettingsScreen> {
  String _selectedTheme = 'dark'; // 'system', 'light', 'dark'

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
                        'Themes',
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
                      'App Appearance',
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
                          _ThemeOptionRow(
                            icon: Icons.brightness_auto_rounded,
                            title: 'System Default',
                            isSelected: _selectedTheme == 'system',
                            onTap: () => setState(() => _selectedTheme = 'system'),
                          ),
                          _ThemeOptionRow(
                            icon: Icons.dark_mode_rounded,
                            title: 'Dark Mode',
                            isSelected: _selectedTheme == 'dark',
                            onTap: () => setState(() => _selectedTheme = 'dark'),
                          ),
                          _ThemeOptionRow(
                            icon: Icons.light_mode_rounded,
                            title: 'Light Mode',
                            isSelected: _selectedTheme == 'light',
                            isLast: true,
                            onTap: () => setState(() => _selectedTheme = 'light'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Note section
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Colors.greenAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Wazi is currently optimized for Dark Mode.',
                            style: WaziText.inter(size: 12, color: Colors.white54),
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

class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLast;

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
                style: WaziText.inter(size: 15, weight: FontWeight.w500, color: Colors.white),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 24)
            else
              const Icon(Icons.radio_button_unchecked_rounded, color: Colors.white30, size: 24),
          ],
        ),
      ),
    );
  }
}
