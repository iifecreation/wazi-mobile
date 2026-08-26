import 'package:flutter/material.dart';

import '../api/requests_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pill_toggle.dart';

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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.home),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 6),
                Text('Settings', style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
              ],
            ),
            const SizedBox(height: 28),
            _sectionLabel('VOICE & AI'),
            const SizedBox(height: 10),
            _Card(children: [
              _ToggleRow(
                title: 'Speak responses aloud',
                subtitle: 'Wazi replies with voice, not just text',
                value: appState.speak,
                onTap: appState.toggleSpeak,
              ),
              _ToggleRow(
                title: 'Ask before sensitive info',
                subtitle: "Check I'm private before saying balances",
                value: appState.ask,
                onTap: appState.toggleAsk,
              ),
              _ToggleRow(
                title: 'Earpiece connected',
                subtitle: 'Demo toggle — skips the privacy check',
                value: appState.head,
                onTap: appState.toggleHead,
              ),
              _NavRow(
                title: 'Re-record voiceprint',
                trailing: appState.enrolling ? 'Listening…' : (appState.enrolled ? 'Saved just now →' : 'Tap to record →'),
                trailingColor: WaziColors.teal,
                onTap: appState.enrolling ? () {} : appState.startEnroll,
                isLast: true,
              ),
            ]),
            const SizedBox(height: 26),
            _sectionLabel('SECURITY'),
            const SizedBox(height: 10),
            _Card(children: [
              _NavRow(title: 'Change PIN', trailing: '→', trailingColor: WaziColors.textAt(.4), onTap: appState.openPin),
              _ToggleRow(
                title: 'Face ID for large transfers',
                value: appState.face,
                onTap: appState.toggleFace,
                isLast: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily voice-transfer limit', style: WaziText.inter(size: 15)),
                        Text(
                          appState.regStatus?.limits.dailyLimitFormatted ?? '···',
                          style: WaziText.grotesk(size: 15, weight: FontWeight.w500, color: WaziColors.gold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      appState.regStatus != null
                          ? 'Tier ${appState.regStatus!.tier}${appState.regStatus!.limits.maxBalanceFormatted != null ? ' · balance up to ${appState.regStatus!.limits.maxBalanceFormatted}' : ' · no balance cap'}. Resets daily.'
                          : 'Sign in to see your tier limit.',
                      style: WaziText.inter(size: 12, color: WaziColors.textAt(.4)),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 26),
            _sectionLabel('EMERGENCY'),
            const SizedBox(height: 10),
            _Card(children: [
              _NavRow(
                title: 'Duress PIN',
                trailing: (appState.duressStatus?.hasDuressPin ?? false) ? 'Set →' : 'Set up →',
                trailingColor: WaziColors.teal,
                onTap: () => _showSetDuressPinDialog(context, appState),
              ),
              _NavRow(
                title: 'Trusted contact',
                trailing: appState.duressStatus?.hasTrustedContact ?? false ? 'Set →' : 'Add →',
                trailingColor: WaziColors.teal,
                onTap: () => _showSetTrustedContactDialog(context, appState),
                isLast: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 17),
                child: Text(
                  'If you\'re ever forced to pay, enter your duress PIN instead of your real one at the PIN sheet. '
                  'It looks and sounds exactly like a normal successful payment — no money actually moves, and your '
                  'trusted contact is quietly alerted.',
                  style: WaziText.inter(size: 12, color: WaziColors.textAt(.4), height: 1.4),
                ),
              ),
            ]),
            const SizedBox(height: 26),
            _sectionLabel('MONEY REQUESTS'),
            const SizedBox(height: 10),
            if (appState.requestInbox == null)
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: CircularProgressIndicator()))
            else if (appState.requestInbox!.where((r) => r.status == 'pending').isEmpty)
              _Card(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                  child: Text(
                    'Nothing waiting on you right now. Say "I need 5000 naira from Mum for data" to send a request '
                    'the other way.',
                    style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
                  ),
                ),
              ])
            else
              _Card(
                children: appState.requestInbox!.where((r) => r.status == 'pending').toList().asMap().entries.map((e) {
                  final isLast = e.key == appState.requestInbox!.where((r) => r.status == 'pending').length - 1;
                  return _RequestRow(request: e.value, appState: appState, isLast: isLast);
                }).toList(),
              ),
            const SizedBox(height: 26),
            _sectionLabel('PREFERENCES'),
            const SizedBox(height: 10),
            _Card(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voice language', style: WaziText.inter(size: 15)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: _langs.map((l) {
                        final active = appState.lang == l;
                        return GestureDetector(
                          onTap: () => appState.pickLang(l),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: active ? WaziColors.tealAt(.14) : Colors.transparent,
                              border: Border.all(color: active ? WaziColors.tealAt(.5) : WaziColors.textAt(.12)),
                            ),
                            child: Text(l, style: WaziText.inter(size: 12.5, color: active ? WaziColors.teal : WaziColors.textAt(.7))),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              _NavRow(title: 'Notifications', trailing: 'All transfers →', trailingColor: WaziColors.textAt(.45), onTap: appState.openNotif, isLast: true),
            ]),
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
