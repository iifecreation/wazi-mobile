import 'package:flutter/material.dart';

import '../api/lifestyle_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class OJuniorScreen extends StatefulWidget {
  const OJuniorScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<OJuniorScreen> createState() => _OJuniorScreenState();
}

class _OJuniorScreenState extends State<OJuniorScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  bool _submitting = false;
  String? _error;
  List<JuniorAccountOut> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final userId = widget.appState.userId;
    if (userId == null) { setState(() => _loading = false); return; }
    try {
      final list = await widget.appState.lifestyleApi.listJuniorAccounts(userId);
      if (!mounted) return;
      setState(() { _accounts = list; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; });
    }
  }

  Future<void> _create() async {
    final userId = widget.appState.userId;
    if (userId == null) return;
    final name = _nameController.text.trim();
    final dob = _dobController.text.trim();
    if (name.isEmpty || dob.isEmpty) { setState(() => _error = 'Please fill in both fields.'); return; }
    setState(() { _submitting = true; _error = null; });
    try {
      await widget.appState.lifestyleApi.createJuniorAccount(userId, name, dob);
      _nameController.clear();
      _dobController.clear();
      await _load();
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Junior account created for $name!'),
        backgroundColor: Colors.green.shade800,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Failed: $e'; _submitting = false; });
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
            Text('Wazi Junior', style: WaziText.grotesk(size: 18, weight: FontWeight.w600, color: Colors.white)),
            const Spacer(),
            const SizedBox(width: 20),
          ]),
        ),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.child_care_rounded, size: 70, color: Colors.greenAccent),
              ),
              const SizedBox(height: 24),
              Text('Financial Freedom\nfor Your Kids', style: WaziText.inter(size: 22, weight: FontWeight.w800, color: Colors.white, height: 1.2), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Create a sub-account for your children to teach them how to save, spend, and manage money safely.',
                style: WaziText.inter(size: 14, color: WaziColors.textAt(0.5), height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 32),

              // Create form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Create Junior Account', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 16),
                  _Field(_nameController, "Child's full name"),
                  const SizedBox(height: 12),
                  _Field(_dobController, 'Date of birth (DD/MM/YYYY)'),
                  if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _create,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: WaziColors.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Create Account', style: WaziText.inter(size: 15, weight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),

              // Existing accounts
              if (_accounts.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text('Your Kids', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                const SizedBox(height: 14),
                ..._accounts.map((j) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
                  child: Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.child_care_rounded, color: Colors.greenAccent, size: 22)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(j.childName, style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white)),
                      Text('Acct: ${j.accountNumber}', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.4))),
                      Text('Balance: ${j.balanceFormatted}', style: WaziText.inter(size: 12, color: WaziColors.teal)),
                    ])),
                    if (j.cardFrozen)
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Frozen', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w600))),
                  ]),
                )),
              ] else ...[
                const SizedBox(height: 24),
                _FeatureRow(icon: Icons.account_balance_wallet_rounded, title: 'Set Allowances', description: 'Automate weekly pocket money.'),
                _FeatureRow(icon: Icons.track_changes_rounded, title: 'Monitor Spending', description: 'Real-time alerts on purchases.'),
                _FeatureRow(icon: Icons.security_rounded, title: 'Full Parental Control', description: 'Lock cards or set spending limits.'),
              ],
              const SizedBox(height: 32),
            ]),
          )),
      ])),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.controller, this.hint);
  final TextEditingController controller; final String hint;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
    child: TextField(controller: controller, style: WaziText.inter(size: 15, color: Colors.white),
      decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: WaziText.inter(size: 15, color: WaziColors.textAt(0.35)), isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12))),
  );
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.description});
  final IconData icon; final String title; final String description;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
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
