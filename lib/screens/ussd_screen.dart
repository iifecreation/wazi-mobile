import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/lifestyle_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class UssdScreen extends StatefulWidget {
  const UssdScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<UssdScreen> createState() => _UssdScreenState();
}

class _UssdScreenState extends State<UssdScreen> {
  UssdInfo? _ussd;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = widget.appState.userId;
    if (userId == null) { setState(() => _loading = false); return; }
    try {
      final ussd = await widget.appState.lifestyleApi.getUssd(userId);
      if (!mounted) return;
      setState(() { _ussd = ussd; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Could not load USSD codes.'; _loading = false; });
    }
  }

  void _copy(String code, String label) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied: $code'), backgroundColor: WaziColors.card),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => widget.appState.go(AppScreen.settings),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
            ),
            const SizedBox(width: 16),
            Text('Wazi USSD', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
          ]),
        ),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))))
        else
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WaziColors.teal.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: WaziColors.teal.withValues(alpha: 0.15)),
                ),
                child: Row(children: [
                  const Icon(Icons.phone_in_talk_rounded, color: WaziColors.teal, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_ussd!.note, style: WaziText.inter(size: 13, color: WaziColors.teal))),
                ]),
              ),
              const SizedBox(height: 24),
              _CodeRow('Check Balance', _ussd!.balanceCheck, () => _copy(_ussd!.balanceCheck, 'Balance check code')),
              _CodeRow('Transfer Money', _ussd!.transfer, () => _copy(_ussd!.transfer, 'Transfer code')),
              _CodeRow('Buy Airtime', _ussd!.airtime, () => _copy(_ussd!.airtime, 'Airtime code')),
              _CodeRow('Mini Statement', _ussd!.miniStatement, () => _copy(_ussd!.miniStatement, 'Mini statement code')),
              _CodeRow('Main Menu', _ussd!.defaultCode, () => _copy(_ussd!.defaultCode, 'Main menu code')),
              const SizedBox(height: 32),
            ]),
          )),
      ])),
    );
  }

  Widget _CodeRow(String label, String code, VoidCallback onCopy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WaziColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: WaziText.inter(size: 14, color: WaziColors.textAt(0.6))),
            const SizedBox(height: 4),
            Text(code, style: WaziText.grotesk(size: 18, weight: FontWeight.w700, color: WaziColors.gold, letterSpacing: 1)),
          ],
        )),
        GestureDetector(
          onTap: onCopy,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: WaziColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.copy_rounded, color: WaziColors.gold, size: 18),
          ),
        ),
      ]),
    );
  }
}
