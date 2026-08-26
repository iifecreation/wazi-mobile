import 'package:flutter/material.dart';

import '../api/accounts_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

const _barPalette = [WaziColors.gold, WaziColors.gold, WaziColors.gold, WaziColors.teal, WaziColors.teal, WaziColors.text];

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  SpendSummaryResponse? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = widget.appState.userId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final summary = await widget.appState.accountsApi.getSpendSummary(userId);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load spending.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final breakdown = _summary?.breakdown ?? const [];
    final maxTotal = breakdown.isEmpty ? 1.0 : breakdown.map((b) => _parseNaira(b.totalFormatted)).reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.home),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                ),
                Text('THIS MONTH', style: WaziText.grotesk(size: 13, weight: FontWeight.w500, color: WaziColors.textAt(.5), letterSpacing: 1.4)),
                GestureDetector(
                  onTap: appState.onMic,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: WaziColors.tealAt(.14)),
                    child: const Icon(Icons.mic_rounded, size: 16, color: WaziColors.teal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text('TOTAL SPENT', style: WaziText.inter(size: 12, color: WaziColors.textAt(.45), letterSpacing: 1.3)),
            const SizedBox(height: 6),
            if (_loading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator())
            else ...[
              Text(_summary?.totalSpentFormatted ?? '₦0.00', style: WaziText.grotesk(size: 44, weight: FontWeight.w600, letterSpacing: -1.3)),
              Text(
                _error ?? _summary?.narration ?? 'No spending recorded yet.',
                style: WaziText.inter(size: 13.5, color: WaziColors.gold),
              ),
              if (breakdown.isNotEmpty) ...[
                const SizedBox(height: 30),
                SizedBox(
                  height: 170,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: breakdown.asMap().entries.map((e) {
                      final value = _parseNaira(e.value.totalFormatted);
                      final height = maxTotal == 0 ? 8.0 : 10 + (value / maxTotal) * 148;
                      final color = _barPalette[e.key % _barPalette.length];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [color.withValues(alpha: .8), color.withValues(alpha: .16)],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: breakdown
                      .map((b) => Expanded(
                            child: Text(
                              _titleCase(b.category).toUpperCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: WaziText.inter(size: 10.5, color: WaziColors.textAt(.45), letterSpacing: .8),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 30),
                Column(
                  children: breakdown.asMap().entries.map((e) {
                    final isLast = e.key == breakdown.length - 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
                      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.07)))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_titleCase(e.value.category), style: WaziText.inter(size: 15)),
                          Text(e.value.totalFormatted, style: WaziText.grotesk(size: 15, weight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: [WaziColors.tealAt(.12), WaziColors.tealAt(.03)]),
                    border: Border.all(color: WaziColors.tealAt(.24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WAZI NOTICED', style: WaziText.grotesk(size: 11.5, weight: FontWeight.w600, color: WaziColors.teal, letterSpacing: 1.7)),
                      const SizedBox(height: 10),
                      Text(
                        'Your biggest category was ${_titleCase(breakdown.first.category)} at ${breakdown.first.totalFormatted}, across ${breakdown.first.transactionCount} transactions.',
                        style: WaziText.inter(size: 14.5, height: 1.5, color: WaziColors.textAt(.85)),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: appState.askBudget,
                        child: Container(
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: WaziColors.tealAt(.4)))),
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('Ask Wazi to cap transport', style: WaziText.inter(size: 13, color: WaziColors.teal)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _titleCase(String s) =>
      s.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  double _parseNaira(String formatted) {
    final digits = formatted.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(digits) ?? 0;
  }
}
