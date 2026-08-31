import 'dart:ui';
import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../api/accounts_api.dart';
import '../widgets/bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hideBalance = false;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  bool _loadingTxs = true;
  String? _txError;
  List<TransactionOut> _recentTxs = [];

  @override
  void initState() {
    super.initState();
    _loadTxs();
  }

  Future<void> _loadTxs() async {
    final userId = widget.appState.userId;
    if (userId == null) {
      if (mounted) setState(() => _loadingTxs = false);
      return;
    }
    try {
      final res = await widget.appState.accountsApi.getTransactions(userId);
      if (!mounted) return;
      setState(() {
        _recentTxs = res.transactions.take(3).toList();
        _loadingTxs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _txError = 'Could not load transactions';
        _loadingTxs = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.appState.regStatus?.firstName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by AppRoot
      bottomNavigationBar: WaziBottomNav(appState: widget.appState),
      body: Stack(
        children: [
          // Subtle animated background gradients
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WaziColors.teal.withValues(alpha: 0.12),
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
              width: 300,
              height: 300,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Info
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: const Center(
                              child: Icon(Icons.person, color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello,', style: WaziText.inter(size: 13, color: WaziColors.textAt(.6))),
                              Text(name, style: WaziText.grotesk(size: 18, weight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      
                      // Icons
                      Row(
                        children: [
                          _HeaderIcon(
                            icon: Icons.mic_none_rounded,
                            onTap: () => widget.appState.go(AppScreen.home),
                            color: WaziColors.teal,
                            bgColor: WaziColors.teal.withValues(alpha: 0.15),
                          ),
                          const SizedBox(width: 8),
                          _HeaderIcon(
                            icon: Icons.notifications_none_rounded,
                            onTap: widget.appState.openNotif,
                            hasBadge: true,
                          ),
                          const SizedBox(width: 8),
                          _HeaderIcon(
                            icon: Icons.headset_mic_outlined,
                            onTap: widget.appState.openSupport,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Account Cards
                SizedBox(
                  height: 220,
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildAccountCard(
                        currency: 'NGN',
                        name: 'Naira Account',
                        balance: widget.appState.balance?.balanceFormatted ?? '₦0.00',
                        color: WaziColors.teal,
                      ),
                      _buildAccountCard(
                        currency: 'USD',
                        name: 'Dollar Account',
                        balance: '\$0.00',
                        color: WaziColors.gold,
                      ),
                      _buildAddAccountCard(),
                    ],
                  ),
                ),
                               // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [
                      _QuickAction(
                        icon: Icons.arrow_upward_rounded,
                        label: 'Send money',
                        onTap: () => widget.appState.go(AppScreen.sendMoney),
                      ),
                      _QuickAction(
                        icon: Icons.attach_money_rounded,
                        label: 'International',
                        onTap: () => widget.appState.go(AppScreen.international),
                      ),
                      _QuickAction(
                        icon: Icons.receipt_long_rounded,
                        label: 'Airtime & data',
                        onTap: () => widget.appState.go(AppScreen.airtime),
                      ),
                      _QuickAction(
                        icon: Icons.payment_rounded,
                        label: 'Pay bills',
                        onTap: () => widget.appState.go(AppScreen.payBills),
                      ),
                      _QuickAction(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan to pay',
                        iconColor: WaziColors.teal,
                        onTap: () => widget.appState.go(AppScreen.scan),
                      ),
                      _QuickAction(
                        icon: Icons.arrow_downward_rounded,
                        label: 'Request',
                        onTap: () => widget.appState.go(AppScreen.requestMoney),
                      ),
                      _QuickAction(
                        icon: Icons.credit_card_outlined,
                        label: 'Cards',
                        onTap: () => widget.appState.go(AppScreen.cards),
                      ),
                      _QuickAction(
                        icon: Icons.track_changes_rounded,
                        label: 'Savings',
                        onTap: () => widget.appState.go(AppScreen.savings),
                      ),
                      _QuickAction(
                        icon: Icons.grid_view_rounded,
                        label: 'More',
                        onTap: () => widget.appState.go(AppScreen.services),
                      ),
                    ],
                  ),
                ),
                
                // Recent Activity
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Activity', style: WaziText.grotesk(size: 18, weight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 24),
                      _loadingTxs 
                        ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                        : _txError != null 
                          ? Center(child: Padding(padding: EdgeInsets.all(24), child: Text(_txError!, style: TextStyle(color: Colors.red))))
                          : _recentTxs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 40),
                                    Icon(Icons.receipt_long_outlined, size: 48, color: WaziColors.textAt(0.2)),
                                    const SizedBox(height: 16),
                                    Text('No recent transactions', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.5))),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              )
                            : Column(
                                children: _recentTxs.map((tx) {
                                  final isCredit = tx.direction == 'in';
                                  IconData icon = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
                                  if (tx.category == 'airtime') icon = Icons.phone_android_rounded;
                                  if (tx.category == 'electricity') icon = Icons.lightbulb_outline_rounded;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _TransactionTile(
                                      title: tx.counterparty.isEmpty ? tx.description : tx.counterparty,
                                      subtitle: '${tx.occurredAt.month}/${tx.occurredAt.day} • ${tx.category}',
                                      amount: '${isCredit ? '+' : '-'}${tx.amountFormatted}',
                                      isCredit: isCredit,
                                      status: 'Success', // Mocked as API doesn't return status yet
                                      icon: icon,
                                    ),
                                  );
                                }).toList(),
                              ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({required String currency, required String name, required String balance, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(currency, style: WaziText.inter(size: 12, weight: FontWeight.w600, color: color)),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _hideBalance = !_hideBalance),
                icon: Icon(
                  _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: WaziText.inter(size: 14, color: WaziColors.textAt(0.6))),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _hideBalance ? '•••••••' : balance,
              key: ValueKey(_hideBalance),
              style: WaziText.grotesk(size: 32, weight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () => widget.appState.go(AppScreen.insights),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardButton(
                  icon: Icons.add_rounded,
                  label: 'Add Money',
                  primary: true,
                  onTap: () {
                    // Placeholder for Add Money flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Add Money coming soon!'),
                        backgroundColor: WaziColors.teal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAddAccountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(28),
      ),
      // Add dashed border effect
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('New currencies coming soon!'),
                backgroundColor: WaziColors.gold,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white70, size: 28),
                ),
                const SizedBox(height: 16),
                Text('Add Account', style: WaziText.inter(size: 15, weight: FontWeight.w500, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    this.hasBadge = false,
    this.color = Colors.white70,
    this.bgColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool hasBadge;
  final Color color;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor ?? Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          if (hasBadge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WaziColors.gold,
                  border: Border.all(color: WaziColors.bg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: primary ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: primary ? 0 : 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: WaziText.inter(size: 13, weight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = WaziColors.gold,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: WaziText.inter(size: 13, color: Colors.white, weight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.status,
    required this.icon,
    this.isFailed = false,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final String status;
  final IconData icon;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCredit ? Colors.greenAccent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isCredit ? Colors.greenAccent : Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: WaziText.inter(size: 12, color: Colors.white54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: WaziText.inter(
                size: 15, 
                weight: FontWeight.w700, 
                color: isCredit ? Colors.greenAccent : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: WaziText.inter(
                size: 11, 
                color: isFailed ? Colors.redAccent : (status == 'Success' ? Colors.white54 : WaziColors.gold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
