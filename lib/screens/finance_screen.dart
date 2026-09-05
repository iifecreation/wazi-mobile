import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../api/finance_api.dart';
import '../widgets/bottom_nav.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  bool _loading = true;
  String? _error;
  FinanceResponse? _data;

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
      final res = await widget.appState.financeApi.getFinance(userId);
      if (!mounted) return;
      setState(() {
        _data = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load finance data';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: WaziBottomNav(appState: widget.appState),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text('Finance', style: WaziText.grotesk(size: 24, weight: FontWeight.w600, color: Colors.white)),
                  const Spacer(),
                  Icon(Icons.pie_chart_outline_rounded, color: Colors.white.withValues(alpha: 0.5)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs
                    Row(
                      children: [
                        _buildTab(title: 'Analytics', active: true),
                        const SizedBox(width: 12),
                        _buildTab(title: 'Wealth', active: false),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Monthly Summary
                    Text('Monthly Summary', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    else if (_data != null) ...[
                      Row(
                        children: [
                          _buildSummaryCard(title: 'Income', amount: _data!.incomeFormatted, icon: Icons.arrow_downward_rounded, color: WaziColors.teal),
                          const SizedBox(width: 16),
                          _buildSummaryCard(title: 'Spent', amount: _data!.spentFormatted, icon: Icons.arrow_upward_rounded, color: Colors.redAccent),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Top Categories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Top Categories', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                          Text('See All', style: WaziText.inter(size: 12, weight: FontWeight.w500, color: WaziColors.gold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._data!.categories.asMap().entries.map((entry) {
                        const palette = [Colors.orange, Colors.blue, Colors.purple, Colors.green, Colors.teal, Colors.pinkAccent];
                        final color = palette[entry.key % palette.length];
                        final c = entry.value;
                        return _buildCategoryRow(title: c.title, amount: c.amountFormatted, percent: c.percent, color: color);
                      }),
                      const SizedBox(height: 32),
                      
                      // Goals
                      Text('Savings Goals', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                      const SizedBox(height: 16),
                      ..._data!.goals.map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildGoalCard(title: g.title, current: g.currentFormatted, target: g.targetFormatted ?? g.currentFormatted, progress: g.progress ?? 0.0),
                      )),
                    ],
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

  Widget _buildTab({required String title, required bool active}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: WaziText.inter(
              size: 14,
              weight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? Colors.white : WaziColors.textAt(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String amount, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 12),
            Text(title, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
            const SizedBox(height: 4),
            Text(amount, style: WaziText.grotesk(size: 18, weight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow({required String title, required String amount, required double percent, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.category_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
                    Text(amount, style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({required String title, required String current, required String target, required double progress}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
              Text('$current / $target', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(WaziColors.gold),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
