import 'dart:ui';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String _lastPhone = '';
  String _lastPass = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    
    _phoneController.addListener(() {
      if (_phoneController.text != _lastPhone) {
        _lastPhone = _phoneController.text;
        setState(() {});
      }
    });
    
    _passwordController.addListener(() {
      if (_passwordController.text != _lastPass) {
        _lastPass = _passwordController.text;
        setState(() {});
      }
    });
    
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String get _fullPhone => '+234${_phoneController.text.trim()}';

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await widget.appState.login(_fullPhone, _passwordController.text);
  }

  Future<String?> _promptText(
    BuildContext context, {
    required String title,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WaziColors.card,
        title: Text(title, style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: WaziText.inter(size: 16, color: Colors.white),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white38)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Continue')),
        ],
      ),
    );
  }

  /// The same forgot-password flow voice drives (app/dialogue/onboarding.py:
  /// phone -> mocked OTP -> new password, typed here rather than said out
  /// loud), just through the real REST endpoints
  /// (registrationApi.forgotPasswordStart/Reset) instead of a spoken
  /// transcript.
  Future<void> _startForgotPassword() async {
    final phoneDigits = await _promptText(
      context,
      title: 'Reset password',
      hint: 'Phone number (e.g. 8012345678)',
      keyboardType: TextInputType.phone,
    );
    if (phoneDigits == null || phoneDigits.isEmpty || !mounted) return;
    final fullPhone = '+234$phoneDigits';

    try {
      await widget.appState.registrationApi.forgotPasswordStart(fullPhone);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
      return;
    }
    if (!mounted) return;

    final otp = await _promptText(context, title: 'Enter the code', hint: 'Code sent to your phone', keyboardType: TextInputType.number);
    if (otp == null || otp.isEmpty || !mounted) return;

    final newPassword = await _promptText(context, title: 'New password', hint: 'New password', obscure: true);
    if (newPassword == null || newPassword.isEmpty || !mounted) return;

    try {
      await widget.appState.registrationApi.forgotPasswordReset(fullPhone, otp, newPassword);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset. Sign in with your new password.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by AppRoot
      body: Stack(
        children: [
          // Subtle animated background gradients
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WaziColors.teal.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WaziColors.gold.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
              child: AnimatedBuilder(
                animation: widget.appState,
                builder: (context, _) {
                  final appState = widget.appState;
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => appState.go(AppScreen.welcome),
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                            padding: const EdgeInsets.all(12),
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Welcome back',
                            style: WaziText.grotesk(size: 34, weight: FontWeight.w700, letterSpacing: -1.0, height: 1.1).copyWith(
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: [Colors.white, Colors.white.withValues(alpha: 0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('Sign in securely with your phone number and password.', style: WaziText.inter(size: 15, color: WaziColors.textAt(.6), height: 1.4)),
                          const SizedBox(height: 36),
                          
                          // Glassmorphic Input Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('PHONE NUMBER'),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: WaziColors.textAt(.05)),
                                      ),
                                      child: Row(
                                        children: [
                                          Text('+234', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.teal)),
                                          const SizedBox(width: 12),
                                          Container(width: 1, height: 20, color: WaziColors.textAt(.14)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              style: WaziText.grotesk(size: 18, weight: FontWeight.w600, letterSpacing: 1.5, color: Colors.white),
                                              cursorColor: WaziColors.teal,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '802 431 9902',
                                                hintStyle: WaziText.grotesk(size: 18, weight: FontWeight.w500, letterSpacing: 1.5, color: WaziColors.textAt(.2)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _label('PASSWORD'),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: WaziColors.textAt(.05)),
                                      ),
                                      child: TextField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        style: WaziText.grotesk(size: 18, weight: FontWeight.w600, letterSpacing: 1.5, color: Colors.white),
                                        cursorColor: WaziColors.teal,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter your password',
                                          hintStyle: WaziText.grotesk(size: 16, weight: FontWeight.w500, letterSpacing: 0, color: WaziColors.textAt(.2)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _startForgotPassword,
                              child: Text('Forgot password?', style: WaziText.inter(size: 13.5, weight: FontWeight.w500, color: WaziColors.teal)),
                            ),
                          ),

                          if (appState.error != null) ...[
                            const SizedBox(height: 24),
                            Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Text(appState.error!, style: WaziText.inter(size: 13, color: Colors.redAccent)),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 48),
                          
                          // Premium Button
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                if (_phoneController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty && !appState.busy)
                                  BoxShadow(
                                    color: WaziColors.teal.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                              ],
                              gradient: LinearGradient(
                                colors: (_phoneController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty && !appState.busy)
                                    ? [WaziColors.teal, Color(0xFF38B2A1)]
                                    : [WaziColors.textAt(0.1), WaziColors.textAt(0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: (_phoneController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty && !appState.busy) ? _submit : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Center(
                                    child: appState.busy
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                                        : Text(
                                            'Sign In',
                                            style: WaziText.grotesk(
                                              size: 17,
                                              weight: FontWeight.w700,
                                              color: (_phoneController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty && !appState.busy)
                                                  ? WaziColors.bg
                                                  : WaziColors.textAt(0.3),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text, style: WaziText.inter(size: 12, color: WaziColors.textAt(.5), letterSpacing: 1.5, weight: FontWeight.w600));
}
