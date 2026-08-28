import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ClipboardSettingsScreen extends StatefulWidget {
  const ClipboardSettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ClipboardSettingsScreen> createState() => _ClipboardSettingsScreenState();
}

class _ClipboardSettingsScreenState extends State<ClipboardSettingsScreen> {
  bool _readClipboard = true;

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
                        'Clipboard Settings',
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
                      'Smart Paste',
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
                          _ClipboardToggleRow(
                            icon: Icons.content_paste_rounded,
                            title: 'Read Clipboard',
                            subtitle: 'Automatically detect copied account numbers or phone numbers to speed up transfers',
                            value: _readClipboard,
                            isLast: true,
                            onChanged: (val) => setState(() => _readClipboard = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Note section
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.security_rounded, size: 16, color: Colors.greenAccent),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Wazi respects your privacy. We only use clipboard data to assist you with transfers and never store your copied text on our servers.',
                              style: WaziText.inter(size: 12, color: Colors.white54),
                            ),
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

class _ClipboardToggleRow extends StatelessWidget {
  const _ClipboardToggleRow({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
