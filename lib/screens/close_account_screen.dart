import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CloseAccountScreen extends StatefulWidget {
  const CloseAccountScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CloseAccountScreen> createState() => _CloseAccountScreenState();
}

class _CloseAccountScreenState extends State<CloseAccountScreen> {
  bool _understandRisk = false;

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
                        'Close Account',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Are you sure you want to close your Wazi account?',
                      style: WaziText.inter(size: 20, weight: FontWeight.w700, color: Colors.white, height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Warning bullet points
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'If you proceed:',
                            style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 16),
                          _WarningBullet(text: 'You will lose access to your Wazi wallet and all associated virtual cards.'),
                          const SizedBox(height: 12),
                          _WarningBullet(text: 'Your transaction history will no longer be accessible through the app.'),
                          const SizedBox(height: 12),
                          _WarningBullet(text: 'Any pending cashbacks or promotional rewards will be forfeited.'),
                          const SizedBox(height: 12),
                          _WarningBullet(text: 'You must withdraw your remaining balance (₦0.00) before closing the account.'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _understandRisk,
                            onChanged: (val) => setState(() => _understandRisk = val ?? false),
                            activeColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.white54, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I understand that this action is permanent and cannot be undone.',
                            style: WaziText.inter(size: 14, color: Colors.white70, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _understandRisk ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.redAccent.withValues(alpha: 0.3),
                          disabledForegroundColor: Colors.white54,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Close My Account', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => widget.appState.go(AppScreen.appSettings),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Keep My Account', style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.greenAccent)),
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

class _WarningBullet extends StatelessWidget {
  const _WarningBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Colors.white54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: WaziText.inter(size: 13, color: Colors.white70, height: 1.4),
          ),
        ),
      ],
    );
  }
}
