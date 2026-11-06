import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/lifestyle_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  ReferralInfo? _referral;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = widget.appState.userId;
    if (userId == null) { setState(() => _loading = false); return; }
    try {
      final r = await widget.appState.lifestyleApi.getReferral(userId);
      if (!mounted) return;
      setState(() { _referral = r; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
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
            Text('Invite Friends', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
          ]),
        ),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_referral == null)
          const Expanded(child: Center(child: Text('Could not load referral info.')))
        else
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(children: [
              // Hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: WaziColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: WaziColors.gold.withValues(alpha: 0.2)),
                ),
                child: Column(children: [
                  const Icon(Icons.celebration_rounded, size: 48, color: WaziColors.gold),
                  const SizedBox(height: 16),
                  Text('Invite Friends & Earn', style: WaziText.grotesk(size: 22, weight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Get ${_referral!.bonusAmountFormatted} for every friend who signs up with your code.',
                    style: WaziText.inter(size: 14, color: WaziColors.textAt(0.6)), textAlign: TextAlign.center),
                ]),
              ),
              const SizedBox(height: 24),

              // Referral code card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: WaziColors.card, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Column(children: [
                  Text('Your Referral Code', style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5))),
                  const SizedBox(height: 8),
                  Text(_referral!.referralCode,
                    style: WaziText.grotesk(size: 32, weight: FontWeight.w800, color: WaziColors.gold, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _referral!.referralLink));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Link copied! Share it with friends.'),
                          backgroundColor: WaziColors.card,
                        ));
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text('Share Link', style: WaziText.inter(size: 15, weight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WaziColors.gold, foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(children: [
                Expanded(child: _StatCard('Friends Invited', '${_referral!.totalInvited}', Icons.group_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard('Total Earned', _referral!.totalEarnedFormatted, Icons.account_balance_wallet_rounded)),
              ]),
              const SizedBox(height: 32),
            ]),
          )),
      ])),
    );
  }

  Widget _StatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: [
        Icon(icon, color: WaziColors.teal, size: 24),
        const SizedBox(height: 8),
        Text(value, style: WaziText.grotesk(size: 20, weight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: WaziText.inter(size: 11, color: WaziColors.textAt(0.5))),
      ]),
    );
  }
}
