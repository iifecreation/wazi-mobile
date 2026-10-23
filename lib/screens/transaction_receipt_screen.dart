import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api_client.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class TransactionReceiptScreen extends StatefulWidget {
  const TransactionReceiptScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<TransactionReceiptScreen> createState() => _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  Map<String, dynamic>? _receipt;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tx = widget.appState.selectedTransaction;
    if (tx == null) {
      setState(() { _loading = false; _error = 'No transaction selected.'; });
      return;
    }
    // If already a full receipt, skip the extra fetch.
    if (tx.containsKey('reference')) {
      setState(() { _receipt = tx; _loading = false; });
      return;
    }
    final userId = widget.appState.userId;
    if (userId == null) {
      setState(() { _loading = false; _error = 'Not signed in.'; });
      return;
    }
    try {
      final data = await widget.appState.apiClient.get(
        '/accounts/$userId/transactions/${tx['id']}',
      );
      if (!mounted) return;
      setState(() { _receipt = data; _loading = false; });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.detail; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Could not load receipt.'; _loading = false; });
    }
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  String _categoryLabel(String cat) => {
    'transport': '🚗 Transport',
    'food': '🍔 Food',
    'airtime_data': '📱 Airtime & Data',
    'utilities': '💡 Utilities',
    'transfer': '💸 Transfer',
    'entertainment': '🎬 Entertainment',
    'shopping': '🛍️ Shopping',
    'income': '💰 Income',
    'other': '📦 Other',
  }[cat] ?? cat;

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
                    onTap: () => widget.appState.go(AppScreen.transactionHistory),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Transaction Receipt', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
                ],
              ),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
            else
              Expanded(child: _buildReceipt(_receipt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt(Map<String, dynamic> r) {
    final isCredit = (r['direction'] as String?) == 'credit';
    final amount = r['amount_formatted'] as String? ?? '';
    final counterparty = r['counterparty'] as String? ?? '';
    final description = r['description'] as String? ?? '';
    final category = r['category'] as String? ?? 'other';
    final reference = r['reference'] as String? ?? r['id'] as String? ?? '';
    final channel = r['channel'] as String? ?? 'wazi_app';
    final fee = r['fee_formatted'] as String? ?? '₦0.00';
    final occurredAt = r['occurred_at'] as String? ?? '';

    DateTime? dt;
    try { dt = DateTime.parse(occurredAt); } catch (_) {}
    final dateLabel = dt != null
        ? '${dt.day} ${_months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : occurredAt;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: WaziColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isCredit ? WaziColors.teal : WaziColors.gold).withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isCredit ? WaziColors.teal : WaziColors.gold, size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${isCredit ? '+' : '-'}$amount',
                  style: WaziText.grotesk(size: 36, weight: FontWeight.w700,
                      color: isCredit ? WaziColors.teal : Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('Successful', style: WaziText.inter(size: 12, color: Colors.green)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ReceiptCard(children: [
            _ReceiptRow('To / From', counterparty.isEmpty ? '—' : counterparty),
            _ReceiptRow('Description', description.isEmpty ? '—' : description),
            _ReceiptRow('Category', _categoryLabel(category)),
            _ReceiptRow('Channel', channel.replaceAll('_', ' ').toUpperCase()),
            _ReceiptRow('Date', dateLabel),
            _ReceiptRow('Fee', fee),
          ]),
          const SizedBox(height: 16),
          _ReceiptCard(children: [
            _ReceiptRow('Reference', reference, monospace: true, copyable: true),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                final text = 'Wazi Transaction Receipt\n'
                    'Amount: ${isCredit ? '+' : '-'}$amount\n'
                    'To/From: $counterparty\n'
                    'Description: $description\n'
                    'Date: $dateLabel\n'
                    'Reference: $reference\n'
                    'Status: Successful';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt copied to clipboard')),
                );
              },
              icon: const Icon(Icons.share_outlined, size: 18),
              label: Text('Share Receipt', style: WaziText.inter(size: 15, weight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: WaziColors.gold,
                side: BorderSide(color: WaziColors.gold.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: WaziColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: Column(children: [
      for (int i = 0; i < children.length; i++) ...[
        children[i],
        if (i < children.length - 1)
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
      ]
    ]),
  );
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, {this.monospace = false, this.copyable = false});
  final String label;
  final String value;
  final bool monospace;
  final bool copyable;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WaziText.inter(size: 13, color: WaziColors.textAt(0.55))),
        const SizedBox(width: 16),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: monospace
                      ? const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')
                      : WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Clipboard.setData(ClipboardData(text: value)),
                  child: Icon(Icons.copy_rounded, size: 14, color: WaziColors.textAt(0.4)),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
