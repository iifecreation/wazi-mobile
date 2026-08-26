import 'package:flutter/material.dart';

import '../api/accounts_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/chat_bubble.dart';

class TypingScreen extends StatelessWidget {
  const TypingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final isChat = appState.tab == BankTab.chat;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: isChat ? _ChatTab(appState: appState) : _BankTab(appState: appState),
          ),
          if (isChat) _DraftInput(appState: appState),
          _BottomNav(appState: appState),
        ],
      ),
    );
  }
}

class _BankTab extends StatefulWidget {
  const _BankTab({required this.appState});

  final AppState appState;

  @override
  State<_BankTab> createState() => _BankTabState();
}

class _BankTabState extends State<_BankTab> {
  List<TransactionOut>? _recent;

  @override
  void initState() {
    super.initState();
    widget.appState.refreshBalance();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final userId = widget.appState.userId;
    if (userId == null) return;
    try {
      final history = await widget.appState.accountsApi.getTransactions(userId, period: 'month');
      if (!mounted) return;
      setState(() => _recent = history.transactions.take(3).toList());
    } catch (_) {
      if (!mounted) return;
      setState(() => _recent = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final actions = <(IconData, String, VoidCallback, Color)>[
      (Icons.arrow_upward_rounded, 'Send money', appState.askSend, WaziColors.gold),
      (Icons.attach_money_rounded, 'International', appState.toChat, WaziColors.gold),
      (Icons.grid_view_rounded, 'Airtime & data', appState.toChat, WaziColors.gold),
      (Icons.receipt_long_rounded, 'Pay bills', appState.toChat, WaziColors.gold),
      (Icons.qr_code_scanner_rounded, 'Scan to pay', () => appState.go(AppScreen.scan), WaziColors.teal),
      (Icons.arrow_downward_rounded, 'Request', appState.toChat, WaziColors.gold),
      (Icons.credit_card_rounded, 'Cards', appState.toChat, WaziColors.gold),
      (Icons.savings_outlined, 'Savings', appState.toChat, WaziColors.gold),
      (Icons.list_alt_rounded, 'History', () => appState.go(AppScreen.insights), WaziColors.gold),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: WaziText.inter(size: 12.5, color: WaziColors.textAt(.45))),
                  Text(
                    appState.regStatus?.phoneNumber ?? appState.userId ?? '',
                    style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => appState.go(AppScreen.home),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: WaziColors.tealAt(.13),
                    border: Border.all(color: WaziColors.tealAt(.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic_rounded, size: 14, color: WaziColors.teal),
                      const SizedBox(width: 8),
                      Text('Voice', style: WaziText.inter(size: 12.5, color: WaziColors.teal)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xFF1B2140), WaziColors.card]),
              border: Border.all(color: WaziColors.textAt(.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NAIRA BALANCE', style: WaziText.inter(size: 11.5, color: WaziColors.textAt(.45), letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(appState.balanceLabel, style: WaziText.grotesk(size: 34, weight: FontWeight.w600, letterSpacing: -1.0)),
                if (appState.regStatus != null) ...[
                  const SizedBox(height: 4),
                  Text('Tier ${appState.regStatus!.tier}', style: WaziText.inter(size: 13, color: WaziColors.textAt(.5))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 26),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: actions.map((a) {
              return GestureDetector(
                onTap: a.$3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: WaziColors.card,
                    border: Border.all(color: WaziColors.textAt(.07)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: a.$4.withValues(alpha: .15)),
                        child: Icon(a.$1, size: 15, color: a.$4),
                      ),
                      const SizedBox(height: 9),
                      Text(a.$2, textAlign: TextAlign.center, style: WaziText.inter(size: 11.5, color: WaziColors.textAt(.8))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Recent', style: WaziText.grotesk(size: 15, weight: FontWeight.w600)),
              GestureDetector(
                onTap: () => appState.go(AppScreen.insights),
                child: Text('See all', style: WaziText.inter(size: 12.5, color: WaziColors.teal)),
              ),
            ],
          ),
          if (_recent == null)
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator()))
          else if (_recent!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No transactions yet.', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.45))),
            )
          else
            ..._recent!.asMap().entries.map((e) {
              final tx = e.value;
              final isCredit = tx.direction == 'credit';
              return _RecentRow(
                icon: isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                bg: isCredit ? const Color(0x14F4F1EA) : WaziColors.goldAt(.14),
                fg: isCredit ? WaziColors.text : WaziColors.gold,
                title: tx.counterparty,
                subtitle: tx.description,
                amount: '${isCredit ? '+' : '−'}${tx.amountFormatted}',
                amountColor: isCredit ? WaziColors.teal : WaziColors.text,
                isLast: e.key == _recent!.length - 1,
              );
            }),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    this.initials,
    this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    this.isLast = false,
  });

  final String? initials;
  final IconData? icon;
  final Color bg;
  final Color fg;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.06)))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            alignment: Alignment.center,
            child: initials != null
                ? Text(initials!, style: WaziText.inter(size: 13, color: fg))
                : Icon(icon, size: 15, color: fg),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaziText.inter(size: 14.5)),
                Text(subtitle, style: WaziText.inter(size: 12, color: WaziColors.textAt(.42))),
              ],
            ),
          ),
          Text(amount, style: WaziText.grotesk(size: 14.5, weight: FontWeight.w500, color: amountColor)),
        ],
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Text('Type to Wazi', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
        const SizedBox(height: 12),
        if (appState.turns.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WaziColors.textAt(.14), style: BorderStyle.solid),
            ),
            child: Text(
              'Same assistant, no talking. Try "send 15k to Amara" or "what did I spend on transport?"',
              style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5)),
            ),
          )
        else
          ...appState.turns.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChatBubble(turn: t, showSpeaking: false),
              )),
      ],
    );
  }
}

class _DraftInput extends StatefulWidget {
  const _DraftInput({required this.appState});

  final AppState appState;

  @override
  State<_DraftInput> createState() => _DraftInputState();
}

class _DraftInputState extends State<_DraftInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.appState.draft);
  }

  @override
  void didUpdateWidget(covariant _DraftInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only resync from state when it diverges from what the field already
    // shows (e.g. cleared to '' after sendDraft) — never on every keystroke,
    // which would fight the user's cursor position.
    if (widget.appState.draft != _controller.text && widget.appState.draft.isEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: WaziColors.card,
          border: Border.all(color: WaziColors.textAt(.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.appState.setDraft,
                onSubmitted: (_) => widget.appState.sendDraft(),
                style: WaziText.inter(size: 14.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a request',
                  hintStyle: WaziText.inter(size: 14.5, color: WaziColors.textAt(.4)),
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.appState.sendDraft,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.gold),
                child: const Icon(Icons.arrow_upward_rounded, size: 18, color: WaziColors.bg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final isBank = appState.tab == BankTab.bank;
    final isChat = appState.tab == BankTab.chat;
    return Container(
      height: 68,
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: WaziColors.bg.withValues(alpha: .94),
        border: Border(top: BorderSide(color: WaziColors.textAt(.07))),
      ),
      child: Row(
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Home', color: isBank ? WaziColors.text : WaziColors.textAt(.45), onTap: appState.toBank),
          _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat', color: isChat ? WaziColors.text : WaziColors.textAt(.45), onTap: appState.toChat),
          Expanded(
            child: GestureDetector(
              onTap: () => appState.go(AppScreen.home),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.teal),
                    child: const Icon(Icons.mic_rounded, size: 16, color: WaziColors.bg),
                  ),
                  const SizedBox(height: 5),
                  Text('Voice', style: WaziText.inter(size: 10.5, color: WaziColors.teal)),
                ],
              ),
            ),
          ),
          _NavItem(icon: Icons.pie_chart_outline_rounded, label: 'Insights', color: WaziColors.textAt(.45), onTap: () => appState.go(AppScreen.insights)),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Me', color: WaziColors.textAt(.45), onTap: () => appState.go(AppScreen.settings)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(label, style: WaziText.inter(size: 10.5, color: color)),
          ],
        ),
      ),
    );
  }
}
