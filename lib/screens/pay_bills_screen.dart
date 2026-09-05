import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

import '../api/bills_api.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  bool _loading = true;
  String? _error;
  BillsResponse? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = widget.appState.userId;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final res = await widget.appState.billsApi.getBills(userId);
      if (!mounted) return;
      setState(() {
        _data = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load bills data';
        _loading = false;
      });
    }
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
                  Text('Pay Bills', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select a Biller Category', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildCategoryCard(icon: Icons.bolt_rounded, label: 'Electricity', color: Colors.orange, onTap: () => widget.appState.go(AppScreen.electricity)),
                        _buildCategoryCard(icon: Icons.tv_rounded, label: 'Cable TV', color: Colors.blue, onTap: () => widget.appState.go(AppScreen.cableTv)),
                        // Internet/Water/Education/Taxes don't have their
                        // own dedicated screen — they all pick from the
                        // same verified-institution registry as
                        // "Pay a Bill Back Home", so that screen (which
                        // already lists every non-telecom institution)
                        // covers them too rather than duplicating four
                        // near-identical picker screens.
                        _buildCategoryCard(icon: Icons.wifi_rounded, label: 'Internet', color: Colors.green, onTap: () => widget.appState.go(AppScreen.international)),
                        _buildCategoryCard(icon: Icons.water_drop_rounded, label: 'Water', color: Colors.cyan, onTap: () => widget.appState.go(AppScreen.international)),
                        _buildCategoryCard(icon: Icons.school_rounded, label: 'Education', color: Colors.purple, onTap: () => widget.appState.go(AppScreen.international)),
                        _buildCategoryCard(icon: Icons.account_balance_rounded, label: 'Taxes', color: Colors.redAccent, onTap: () => widget.appState.go(AppScreen.international)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Recent Bills', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    else if (_data != null)
                      if (_data!.recentBills.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No bills paid yet — pick a category above, or just say "pay electricity bill at Ikeja Electric".',
                            style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5)),
                          ),
                        )
                      else
                        ..._data!.recentBills.map((b) {
                          final isUtility = b.category == 'utilities';
                          return _buildRecentBill(
                            title: b.title,
                            amount: b.amountFormatted,
                            date: _formatBillDate(b.occurredAt),
                            icon: isUtility ? Icons.bolt_rounded : Icons.smartphone_rounded,
                            color: isUtility ? Colors.orange : Colors.green,
                          );
                        }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(label, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String _formatBillDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildRecentBill({required String title, required String amount, required String date, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w500, color: Colors.white)),
                const SizedBox(height: 4),
                Text(date, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
              ],
            ),
          ),
          Text(amount, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
