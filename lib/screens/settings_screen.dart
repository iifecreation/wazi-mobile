import 'package:flutter/material.dart';

import '../api/requests_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pill_toggle.dart';
import '../widgets/bottom_nav.dart';

const _langs = ['English', 'Pidgin', 'Yoruba', 'Igbo', 'Hausa', 'Swahili', 'French'];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.refreshDuressStatus();
    widget.appState.refreshRequestInbox();
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final name = appState.regStatus?.firstName ?? 'USER';
    final balance = '₦23,554.90';
    
    return Scaffold(
      backgroundColor: WaziColors.bg,
      bottomNavigationBar: WaziBottomNav(appState: appState),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: const Center(child: Icon(Icons.person_outline_rounded, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hi, $name', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, color: Colors.white)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: WaziColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.workspace_premium_rounded, size: 12, color: WaziColors.gold),
                                  const SizedBox(width: 4),
                                  Text('Upgrade to Tier 2', style: WaziText.inter(size: 10, color: WaziColors.gold, weight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () => appState.go(AppScreen.appSettings),
                          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Balance Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Total Balance', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                            const SizedBox(width: 8),
                            Icon(Icons.visibility_rounded, size: 16, color: WaziColors.textAt(0.5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(balance, style: WaziText.grotesk(size: 32, weight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Interest Credited Today ', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                              Text('+\$0.09', style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(color: Colors.green.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Security Check Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield_rounded, size: 16, color: Colors.greenAccent),
                                const SizedBox(width: 8),
                                Text('Security Check is not turned on', style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.greenAccent)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Make your account more secure with extra safety checks.', style: WaziText.inter(size: 11, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: Text('Turn On', style: WaziText.inter(size: 12, weight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings Blocks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsRow(icon: Icons.receipt_long_rounded, color: Colors.greenAccent, title: 'Transaction History', onTap: () => appState.go(AppScreen.transactionHistory)),
                      _buildSettingsRow(icon: Icons.speed_rounded, color: Colors.greenAccent, title: 'Account Limits', subtitle: 'View your transaction limits', onTap: () => appState.go(AppScreen.accountLimits)),
                      _buildSettingsRow(icon: Icons.credit_card_rounded, color: Colors.greenAccent, title: 'Bank Card/Account', subtitle: 'Add payment option', onTap: () => appState.go(AppScreen.bankCards)),
                      _buildSettingsRow(icon: Icons.storefront_rounded, color: Colors.greenAccent, title: 'My BizPayment', subtitle: 'Receive payment for business', onTap: () => appState.go(AppScreen.bizPayment)),
                      _buildSettingsRow(icon: Icons.people_alt_rounded, color: Colors.greenAccent, title: 'OJunior', subtitle: 'Create an account for your child/ward', isLast: true, onTap: () => appState.go(AppScreen.oJunior)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsRow(icon: Icons.security_rounded, color: Colors.greenAccent, title: 'Security Center', subtitle: 'Protect your funds', onTap: () => appState.go(AppScreen.securityCenter)),
                      _buildSettingsRow(icon: Icons.support_agent_rounded, color: Colors.greenAccent, title: 'Customer Service Center', onTap: () => appState.go(AppScreen.customerService)),
                      _buildSettingsRow(icon: Icons.celebration_rounded, color: Colors.greenAccent, title: 'Invitation', subtitle: 'Invite friends and earn up to \$10 Bonus', onTap: () => appState.go(AppScreen.invitation)),
                      _buildSettingsRow(icon: Icons.phone_in_talk_rounded, color: Colors.greenAccent, title: 'Wazi USSD', onTap: () => appState.go(AppScreen.ussd)),
                      _buildSettingsRow(icon: Icons.star_rate_rounded, color: Colors.greenAccent, title: 'Rate Us', isLast: true, onTap: () => appState.go(AppScreen.rateUs)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_rounded, size: 16, color: Colors.white54),
                    const SizedBox(width: 8),
                    Text('Licensed by the CBN and insured by the NDIC', style: WaziText.inter(size: 11, color: Colors.white54)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow({required IconData icon, required Color color, required String title, String? subtitle, bool isLast = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: WaziText.inter(size: 15, weight: FontWeight.w500, color: Colors.white)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.45))),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: WaziColors.textAt(0.3), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String s) => Text(s, style: WaziText.inter(size: 11.5, color: WaziColors.textAt(.4), letterSpacing: 1.6));

  Future<void> _showSetDuressPinDialog(BuildContext context, AppState appState) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? localError;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final displayError = localError ?? appState.error;
            return AlertDialog(
              backgroundColor: WaziColors.card,
              title: Text('Set duress PIN', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A different 4-digit PIN from your real one. Entering it under pressure quietly freezes your account instead of moving money.',
                    style: WaziText.inter(size: 12.5, color: WaziColors.textAt(.55), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _dialogPinField(pinController, 'New duress PIN'),
                  const SizedBox(height: 10),
                  _dialogPinField(confirmController, 'Confirm duress PIN'),
                  if (displayError != null) ...[
                    const SizedBox(height: 10),
                    Text(displayError, style: WaziText.inter(size: 12.5, color: WaziColors.gold)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel', style: WaziText.inter(size: 14, color: WaziColors.textAt(.6))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: WaziColors.gold, foregroundColor: WaziColors.bg),
                  onPressed: () async {
                    final pinValue = pinController.text.trim();
                    final confirmValue = confirmController.text.trim();
                    if (pinValue.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pinValue)) {
                      setDialogState(() => localError = 'Enter 4 digits.');
                      return;
                    }
                    if (pinValue != confirmValue) {
                      setDialogState(() => localError = "PINs don't match.");
                      return;
                    }
                    setDialogState(() => localError = null);
                    final ok = await appState.setDuressPin(pinValue);
                    if (ok && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    } else {
                      setDialogState(() {});
                    }
                  },
                  child: Text('Save', style: WaziText.grotesk(size: 14, weight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSetTrustedContactDialog(BuildContext context, AppState appState) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: WaziColors.card,
          title: Text('Trusted contact', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alerted quietly if your duress PIN is ever used.',
                style: WaziText.inter(size: 12.5, color: WaziColors.textAt(.55), height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: WaziText.inter(size: 15),
                decoration: InputDecoration(hintText: 'Name', hintStyle: WaziText.inter(size: 15, color: WaziColors.textAt(.35))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: WaziText.inter(size: 15),
                decoration: InputDecoration(hintText: 'Phone number', hintStyle: WaziText.inter(size: 15, color: WaziColors.textAt(.35))),
              ),
              if (appState.error != null) ...[
                const SizedBox(height: 10),
                Text(appState.error!, style: WaziText.inter(size: 12.5, color: WaziColors.gold)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: WaziText.inter(size: 14, color: WaziColors.textAt(.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: WaziColors.gold, foregroundColor: WaziColors.bg),
              onPressed: () async {
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
                final ok = await appState.setTrustedContact(nameController.text.trim(), phoneController.text.trim());
                if (ok && dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: Text('Save', style: WaziText.grotesk(size: 14, weight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogPinField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      style: WaziText.grotesk(size: 18, weight: FontWeight.w500, letterSpacing: 4),
      decoration: InputDecoration(counterText: '', hintText: hint, hintStyle: WaziText.inter(size: 14, color: WaziColors.textAt(.35))),
    );
  }

}

Future<void> _showApproveRequestDialog(BuildContext context, AppState appState, MoneyRequestOut request) async {
  final pinController = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: WaziColors.card,
            title: Text('Send ${request.amountFormatted}?', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For ${request.reason}${request.deadline != null ? ' · due ${request.deadline}' : ''}.',
                  style: WaziText.inter(size: 12.5, color: WaziColors.textAt(.55), height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  style: WaziText.grotesk(size: 18, weight: FontWeight.w500, letterSpacing: 4),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Your PIN',
                    hintStyle: WaziText.inter(size: 14, color: WaziColors.textAt(.35)),
                  ),
                ),
                if (appState.requestActionError != null) ...[
                  const SizedBox(height: 10),
                  Text(appState.requestActionError!, style: WaziText.inter(size: 12.5, color: WaziColors.gold)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancel', style: WaziText.inter(size: 14, color: WaziColors.textAt(.6))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: WaziColors.gold, foregroundColor: WaziColors.bg),
                onPressed: () async {
                  final pinValue = pinController.text.trim();
                  if (pinValue.length != 4) return;
                  final ok = await appState.approveRequest(request.requestId, pinValue);
                  if (ok && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  } else {
                    setDialogState(() {});
                  }
                },
                child: Text('Send', style: WaziText.grotesk(size: 14, weight: FontWeight.w600)),
              ),
            ],
          );
        },
      );
    },
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: WaziColors.card,
        border: Border.all(color: WaziColors.textAt(.07)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.request, required this.appState, this.isLast = false});

  final MoneyRequestOut request;
  final AppState appState;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.06)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(request.amountFormatted, style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.gold)),
              Text('from ${request.requesterUserId}', style: WaziText.inter(size: 11.5, color: WaziColors.textAt(.4))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'For ${request.reason}${request.deadline != null ? ' · due ${request.deadline}' : ''}',
            style: WaziText.inter(size: 13, color: WaziColors.textAt(.6)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: appState.busy ? null : () => appState.declineRequest(request.requestId),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: WaziColors.textAt(.18)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Decline', style: WaziText.grotesk(size: 13.5, weight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: appState.busy ? null : () => _showApproveRequestDialog(context, appState, request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WaziColors.gold,
                    foregroundColor: WaziColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Approve', style: WaziText.grotesk(size: 13.5, weight: FontWeight.w600, color: WaziColors.bg)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, this.subtitle, required this.value, required this.onTap, this.isLast = false});

  final String title;
  final String? subtitle;
  final bool value;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.06))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: WaziText.inter(size: 15)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: WaziText.inter(size: 12.5, color: WaziColors.textAt(.45))),
                  ],
                ],
              ),
            ),
            PillToggle(value: value),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.title, required this.trailing, required this.trailingColor, required this.onTap, this.isLast = false});

  final String title;
  final String trailing;
  final Color trailingColor;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.06))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: WaziText.inter(size: 15)),
            Text(trailing, style: WaziText.inter(size: 12.5, color: trailingColor)),
          ],
        ),
      ),
    );
  }
}
