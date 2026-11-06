import 'package:flutter/material.dart';

import '../api/lifestyle_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class BizPaymentScreen extends StatefulWidget {
  const BizPaymentScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<BizPaymentScreen> createState() => _BizPaymentScreenState();
}

class _BizPaymentScreenState extends State<BizPaymentScreen> {
  final _bizNameController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  MerchantInfo? _merchant;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkMerchant();
  }

  @override
  void dispose() {
    _bizNameController.dispose();
    super.dispose();
  }

  Future<void> _checkMerchant() async {
    final userId = widget.appState.userId;
    if (userId == null) { setState(() => _loading = false); return; }
    try {
      final m = await widget.appState.lifestyleApi.getMerchant(userId);
      if (!mounted) return;
      setState(() { _merchant = m; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; });
    }
  }

  Future<void> _upgrade() async {
    final userId = widget.appState.userId;
    if (userId == null) return;
    final name = _bizNameController.text.trim();
    if (name.isEmpty) { setState(() => _error = 'Enter your business name.'); return; }
    setState(() { _submitting = true; _error = null; });
    try {
      final m = await widget.appState.lifestyleApi.upgradeToMerchant(userId, name);
      if (!mounted) return;
      setState(() { _merchant = m; _submitting = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Merchant account activated! ${m.businessName}'),
        backgroundColor: Colors.green.shade800,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Upgrade failed: $e'; _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => widget.appState.go(AppScreen.settings),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text('Wazi Business', style: WaziText.grotesk(size: 18, weight: FontWeight.w600, color: Colors.white)),
            const Spacer(),
            const SizedBox(width: 20),
          ]),
        ),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_merchant != null)
          _buildMerchantView()
        else
          _buildUpgradeForm(),
      ])),
    );
  }

  Widget _buildMerchantView() {
    final m = _merchant!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: WaziColors.card, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 60),
            ),
            const SizedBox(height: 16),
            Text('Merchant Account Active', style: WaziText.grotesk(size: 18, weight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(m.businessName, style: WaziText.inter(size: 15, color: WaziColors.textAt(0.6))),
          ]),
        ),
        const SizedBox(height: 24),
        // QR code card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: WaziColors.card, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(children: [
            Text('Your Merchant QR Code', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.6))),
            const SizedBox(height: 16),
            Container(
              width: 160, height: 160,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black87),
                const SizedBox(height: 4),
                Text(m.businessName, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ])),
            ),
            const SizedBox(height: 12),
            Text('Customers scan this to pay you instantly.', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.4)), textAlign: TextAlign.center),
          ]),
        ),
        const SizedBox(height: 24),
        _FeatureRow(icon: Icons.qr_code_2_rounded, title: 'Accept QR Payments', description: 'Display your QR code for customers to scan and pay.'),
        _FeatureRow(icon: Icons.bar_chart_rounded, title: 'Sales Analytics', description: 'Track daily, weekly, and monthly revenue.'),
        _FeatureRow(icon: Icons.group_add_rounded, title: 'Manage Staff', description: 'Add cashiers with restricted permissions.'),
      ]),
    );
  }

  Widget _buildUpgradeForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 160, height: 160,
          decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.storefront_rounded, size: 80, color: Colors.greenAccent),
        ),
        const SizedBox(height: 24),
        Text('Grow Your Business\nwith Wazi', style: WaziText.inter(size: 24, weight: FontWeight.w800, color: Colors.white, height: 1.2), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('Upgrade to a Merchant account to accept payments instantly, manage staff, and track sales.',
          style: WaziText.inter(size: 14, color: WaziColors.textAt(0.5), height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        // Business name input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: _bizNameController,
            style: WaziText.inter(size: 16, color: Colors.white),
            decoration: InputDecoration(border: InputBorder.none, hintText: 'Business name', hintStyle: WaziText.inter(size: 16, color: WaziColors.textAt(0.35))),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        _FeatureRow(icon: Icons.qr_code_2_rounded, title: 'Accept QR Payments', description: 'Let customers scan and pay instantly.'),
        _FeatureRow(icon: Icons.bar_chart_rounded, title: 'Sales Analytics', description: 'Track revenue in real-time.'),
        _FeatureRow(icon: Icons.group_add_rounded, title: 'Manage Staff', description: 'Add cashiers with restricted permissions.'),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _upgrade,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: WaziColors.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Upgrade to Business', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.description});
  final IconData icon; final String title; final String description;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.greenAccent, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 4),
        Text(description, style: WaziText.inter(size: 13, color: WaziColors.textAt(0.4))),
      ])),
    ]),
  );
}
