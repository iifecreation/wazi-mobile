import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  const ReceiveMoneyScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<ReceiveMoneyScreen> createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await widget.appState.loadReceiveDetails();
    if (!mounted) return;
    setState(() => _loading = false);
    if (widget.appState.receiveDetails == null) {
      setState(() => _error = 'Could not load account details.');
    }
  }

  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 2),
        backgroundColor: WaziColors.card,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.appState.go(AppScreen.services),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Receive Money', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
                ],
              ),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))))
            else
              Expanded(child: _buildContent(widget.appState.receiveDetails!)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, String> details) {
    final accountNumber = details['account_number'] ?? '';
    final accountName = details['account_name'] ?? '';
    final bankName = details['bank_name'] ?? 'Wazi MFB';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // QR Code visual (ASCII/CustomPaint placeholder — real QR needs qr_flutter)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: WaziColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                // QR placeholder — replace with QrImageView from qr_flutter if available
                Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black87),
                        const SizedBox(height: 8),
                        Text(
                          'Scan to pay me',
                          style: WaziText.inter(size: 11, color: const Color(0xFF333333)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(accountName,
                    style: WaziText.grotesk(size: 18, weight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(bankName, style: WaziText.inter(size: 13, color: WaziColors.textAt(0.55))),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account number card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: WaziColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Number',
                    style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(accountNumber,
                        style: WaziText.grotesk(size: 28, weight: FontWeight.w700,
                            letterSpacing: 3, color: Colors.white)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _copy(accountNumber, 'Account number'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: WaziColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.copy_rounded, color: WaziColors.gold, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(bankName, style: WaziText.inter(size: 13, color: WaziColors.textAt(0.55))),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Share button
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _copy(
                '$accountName\n$accountNumber\n$bankName',
                'Account details',
              ),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: Text('Share Account Details',
                  style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: WaziColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Info note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WaziColors.teal.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WaziColors.teal.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: WaziColors.teal, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anyone can send you money to this account number from any Nigerian bank.',
                    style: WaziText.inter(size: 12, color: WaziColors.teal.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
