import 'package:flutter/material.dart';

import '../api/fixed_deposits_api.dart';
import '../api/api_client.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class FixedDepositsScreen extends StatefulWidget {
  const FixedDepositsScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<FixedDepositsScreen> createState() => _FixedDepositsScreenState();
}

class _FixedDepositsScreenState extends State<FixedDepositsScreen> {
  List<FdProduct> _products = [];
  List<FdDeposit> _deposits = [];
  bool _loading = true;
  String? _error;

  // Create deposit form state
  FdProduct? _selectedProduct;
  final _amountController = TextEditingController();
  bool _creating = false;
  String? _createError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final products = await widget.appState.fixedDepositsApi.listProducts();
      final userId = widget.appState.userId;
      final deposits = userId != null
          ? await widget.appState.fixedDepositsApi.listDeposits(userId)
          : <FdDeposit>[];
      if (!mounted) return;
      setState(() {
        _products = products;
        _deposits = deposits;
        _loading = false;
        if (products.isNotEmpty) _selectedProduct = products.first;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Could not load fixed deposits.'; _loading = false; });
    }
  }

  // Preview interest for the currently entered amount and selected product.
  String _previewInterest() {
    final product = _selectedProduct;
    final naira = int.tryParse(_amountController.text.trim());
    if (product == null || naira == null || naira <= 0) return '—';
    final amountMinor = naira * 100;
    final interestMinor = (amountMinor * product.ratePercent * product.termMonths / (12 * 100)).toInt();
    final maturityMinor = amountMinor + interestMinor;
    return '₦${_fmt(maturityMinor)} at maturity';
  }

  String _fmt(int minor) {
    final n = minor / 100;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(2);
  }

  Future<void> _createDeposit() async {
    final product = _selectedProduct;
    final naira = int.tryParse(_amountController.text.trim());
    final userId = widget.appState.userId;
    if (product == null || naira == null || naira <= 0 || userId == null) {
      setState(() => _createError = 'Please enter a valid amount and select a term.');
      return;
    }
    if (naira < 1000) {
      setState(() => _createError = 'Minimum deposit is ₦1,000.');
      return;
    }
    setState(() { _creating = true; _createError = null; });
    try {
      final fd = await widget.appState.fixedDepositsApi.createDeposit(userId, naira * 100, product.termMonths);
      if (!mounted) return;
      setState(() {
        _deposits = [fd, ..._deposits];
        _amountController.clear();
        _creating = false;
      });
      await widget.appState.refreshBalance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Fixed deposit created! Matures ${fd.maturityDate} → ${fd.maturityAmountFormatted}'),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
        ));
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _createError = e.detail; _creating = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _createError = 'Failed to create deposit.'; _creating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.appState.go(AppScreen.services),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Fixed Deposits', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
                ],
              ),
            ),

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: WaziColors.gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: WaziColors.gold.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_clock_rounded, color: WaziColors.gold, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Lock your money for a fixed term and earn guaranteed interest — higher than a regular savings account.',
                                style: WaziText.inter(size: 12, color: WaziColors.gold.withValues(alpha: 0.9)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Product cards ─────────────────────────────────────
                      Text('Choose a Term', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 14),
                      Row(
                        children: _products.map((p) {
                          final selected = _selectedProduct?.termMonths == p.termMonths;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() { _selectedProduct = p; _createError = null; }),
                              child: Container(
                                margin: EdgeInsets.only(right: p == _products.last ? 0 : 10),
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? WaziColors.gold.withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selected
                                        ? WaziColors.gold.withValues(alpha: 0.6)
                                        : Colors.white.withValues(alpha: 0.08),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${p.termMonths}M',
                                      style: WaziText.grotesk(
                                        size: 22,
                                        weight: FontWeight.w700,
                                        color: selected ? WaziColors.gold : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p.ratePercent.toStringAsFixed(0)}% p.a.',
                                      style: WaziText.inter(
                                        size: 12,
                                        weight: FontWeight.w600,
                                        color: selected ? WaziColors.gold : WaziColors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.termMonths == 3 ? '3 Months' : p.termMonths == 6 ? '6 Months' : '12 Months',
                                      style: WaziText.inter(size: 10, color: WaziColors.textAt(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // ── Amount input ──────────────────────────────────────
                      Text('Amount (₦)', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: WaziText.grotesk(size: 28, weight: FontWeight.w700, color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: WaziText.grotesk(size: 28, color: WaziColors.textAt(0.3)),
                            prefixText: '₦ ',
                            prefixStyle: WaziText.grotesk(size: 28, weight: FontWeight.w700, color: WaziColors.textAt(0.4)),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Minimum ₦1,000', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.4))),

                      // ── Live payout preview ───────────────────────────────
                      if (_selectedProduct != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: WaziColors.teal.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: WaziColors.teal.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up_rounded, color: WaziColors.teal, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Expected payout: ${_previewInterest()}',
                                  style: WaziText.inter(size: 13, color: WaziColors.teal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_createError != null) ...[
                        const SizedBox(height: 12),
                        Text(_createError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _creating ? null : _createDeposit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WaziColors.gold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _creating
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Lock Funds', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
                        ),
                      ),

                      // ── Existing deposits ─────────────────────────────────
                      if (_deposits.isNotEmpty) ...[
                        const SizedBox(height: 36),
                        Text('Your Deposits', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 14),
                        ..._deposits.map((d) => _DepositCard(deposit: d)),
                      ] else ...[
                        const SizedBox(height: 36),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.lock_outline_rounded, size: 40, color: WaziColors.textAt(0.2)),
                              const SizedBox(height: 12),
                              Text(
                                'No active deposits yet',
                                style: WaziText.inter(size: 14, color: WaziColors.textAt(0.4)),
                              ),
                            ],
                          ),
                        ),
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
}

class _DepositCard extends StatelessWidget {
  const _DepositCard({required this.deposit});
  final FdDeposit deposit;

  @override
  Widget build(BuildContext context) {
    final isActive = deposit.status == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WaziColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deposit.amountFormatted,
                style: WaziText.grotesk(size: 20, weight: FontWeight.w700, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? WaziColors.teal.withValues(alpha: 0.12)
                      : Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Active' : 'Matured',
                  style: WaziText.inter(
                    size: 11,
                    weight: FontWeight.w600,
                    color: isActive ? WaziColors.teal : Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Row('Term', '${deposit.termMonths} months @ ${deposit.ratePercent.toStringAsFixed(0)}% p.a.'),
          _Row('Interest', deposit.interestFormatted),
          _Row('Payout at maturity', deposit.maturityAmountFormatted, highlight: true),
          _Row('Maturity date', deposit.maturityDate),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
        Text(
          value,
          style: highlight
              ? WaziText.grotesk(size: 14, weight: FontWeight.w600, color: WaziColors.gold)
              : WaziText.inter(size: 13, weight: FontWeight.w500, color: Colors.white),
        ),
      ],
    ),
  );
}
