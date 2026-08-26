import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pin_dots.dart';

/// Real login: phone + PIN -> POST /registration/login -> existing user_id.
/// Reachable via Welcome's "I already have an account". The two legacy
/// fixture accounts (rich balance + transaction history) are reachable here
/// via +2348000000001 / PIN 1234 and +2348000000002 / PIN 4321 — see
/// app/registration/fixtures.py on the server.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String _pin = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhone => '+234${_phoneController.text.trim()}';

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await widget.appState.login(_fullPhone, _pin);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: AnimatedBuilder(
          animation: widget.appState,
          builder: (context, _) {
            final appState = widget.appState;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.welcome),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 8),
                Text('Welcome back', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
                const SizedBox(height: 8),
                Text('Sign in with your phone number and PIN.', style: WaziText.inter(size: 14, color: WaziColors.textAt(.55))),
                const SizedBox(height: 26),
                _label('PHONE NUMBER'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  decoration: BoxDecoration(
                    color: WaziColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WaziColors.textAt(.09)),
                  ),
                  child: Row(
                    children: [
                      Text('+234', style: WaziText.grotesk(size: 15, weight: FontWeight.w500, color: WaziColors.textAt(.6))),
                      const SizedBox(width: 10),
                      Container(width: 1, height: 20, color: WaziColors.textAt(.14)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '802 431 9902',
                            hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0, color: WaziColors.textAt(.3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _label('4-DIGIT PIN'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: WaziColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WaziColors.textAt(.09)),
                  ),
                  child: PinDots(length: _pin.length, filled: false),
                ),
                const SizedBox(height: 10),
                _MiniKeypad(
                  onKey: (v) {
                    setState(() {
                      if (v == '⌫') {
                        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
                      } else if (_pin.length < 4) {
                        _pin += v;
                      }
                    });
                  },
                ),
                if (appState.error != null) ...[
                  const SizedBox(height: 14),
                  Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_phoneController.text.trim().isNotEmpty && _pin.length == 4 && !appState.busy) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WaziColors.gold,
                      foregroundColor: WaziColors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: appState.busy
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                        : Text('Sign in', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: WaziText.inter(size: 12, color: WaziColors.textAt(.45), letterSpacing: 1.2));
}

class _MiniKeypad extends StatelessWidget {
  const _MiniKeypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: _keys.map((k) {
        return GestureDetector(
          onTap: k.isEmpty ? null : () => onKey(k),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: k.isEmpty ? Colors.transparent : WaziColors.textAt(.06)),
            alignment: Alignment.center,
            child: Text(k, style: WaziText.grotesk(size: 18, weight: FontWeight.w500)),
          ),
        );
      }).toList(),
    );
  }
}
