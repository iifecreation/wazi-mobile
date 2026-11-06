import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/fx_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/payment_picker_form.dart';

/// International screen — two modes:
/// 1. FX Conversion: convert NGN → USD/GBP/EUR at live rates (Wazi-style)
/// 2. Pay a Bill Back Home: diaspora direct-to-obligation payment (OPay-style)
class InternationalScreen extends StatefulWidget {
  const InternationalScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<InternationalScreen> createState() => _InternationalScreenState();
}

class _InternationalScreenState extends State<InternationalScreen> {
  bool _fxMode = true;

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
                  Text('International', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            // Mode tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildTab(title: 'Convert Money', active: _fxMode, onTap: () => setState(() => _fxMode = true))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTab(title: 'Pay Bill Back Home', active: !_fxMode, onTap: () => setState(() => _fxMode = false))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _fxMode
                    ? _FxConvertForm(appState: widget.appState)
                    : _PayBillForm(appState: widget.appState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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
              size: 13,
              weight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? Colors.white : WaziColors.textAt(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// FX conversion form — pick target currency, enter NGN amount, see live
/// rate + fee, convert to foreign wallet.
class _FxConvertForm extends StatefulWidget {
  const _FxConvertForm({required this.appState});
  final AppState appState;

  @override
  State<_FxConvertForm> createState() => _FxConvertFormState();
}

class _FxConvertFormState extends State<_FxConvertForm> {
  final _amountController = TextEditingController();
  String _toCurrency = 'USD';
  RateQuoteResponse? _quote;
  bool _quoting = false;
  bool _converting = false;
  String? _error;
  String? _success;

  static const _currencies = ['USD', 'GBP', 'EUR'];
  static const _flags = {'USD': '🇺🇸', 'GBP': '🇬🇧', 'EUR': '🇪🇺'};
  static const _names = {
    'USD': 'US Dollar',
    'GBP': 'British Pound',
    'EUR': 'Euro',
  };

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _getQuote() async {
    final naira = int.tryParse(_amountController.text.trim());
    if (naira == null || naira <= 0) return;
    setState(() { _quoting = true; _error = null; _success = null; _quote = null; });
    try {
      final q = await widget.appState.fxApi.getQuote(
        fromCurrency: 'NGN',
        toCurrency: _toCurrency,
        fromAmountMinor: naira * 100,
      );
      if (!mounted) return;
      setState(() { _quote = q; _quoting = false; });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.detail; _quoting = false; });
    }
  }

  Future<void> _convert() async {
    if (_quote == null) return;
    setState(() { _converting = true; _error = null; _success = null; });
    final result = await widget.appState.convertCurrency(
      toCurrency: _toCurrency,
      fromAmountMinor: int.parse(_amountController.text.trim()) * 100,
    );
    if (!mounted) return;
    setState(() => _converting = false);
    if (result != null) {
      setState(() {
        _success = 'Converted ${result.fromAmountFormatted} to ${result.toAmountFormatted}. '
            'Your ${_names[_toCurrency]} wallet has been credited.';
        _quote = null;
      });
      _amountController.clear();
    } else {
      setState(() => _error = widget.appState.error ?? 'Conversion failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Convert your Naira to USD, GBP, or EUR at competitive rates. '
                  'A 1.5% margin and flat ₦500 fee apply.',
                  style: WaziText.inter(size: 12, color: Colors.blue.withValues(alpha: 0.8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Currency picker
        Text('Convert to', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _currencies.map((c) {
            final selected = _toCurrency == c;
            return GestureDetector(
              onTap: () => setState(() { _toCurrency = c; _quote = null; _success = null; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? WaziColors.gold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? WaziColors.gold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_flags[c]!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c, style: WaziText.grotesk(size: 15, weight: FontWeight.w600,
                            color: selected ? WaziColors.gold : Colors.white)),
                        Text(_names[c]!, style: WaziText.inter(size: 11, color: WaziColors.textAt(0.5))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Amount input
        Text('Amount in ₦ (NGN)', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
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
              prefixStyle: WaziText.grotesk(size: 28, weight: FontWeight.w700, color: WaziColors.textAt(0.5)),
            ),
            onChanged: (_) => setState(() { _quote = null; _success = null; _error = null; }),
          ),
        ),
        const SizedBox(height: 16),

        // Get quote button
        SizedBox(
          width: double.infinity, height: 48,
          child: OutlinedButton(
            onPressed: _quoting ? null : _getQuote,
            style: OutlinedButton.styleFrom(
              foregroundColor: WaziColors.teal,
              side: BorderSide(color: WaziColors.teal.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _quoting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Get Live Rate', style: WaziText.inter(size: 14, weight: FontWeight.w600)),
          ),
        ),

        // Quote result
        if (_quote != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: WaziColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WaziColors.teal.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                _QuoteRow('Exchange rate', '1 NGN = ${_quote!.rateWithMargin.toStringAsFixed(6)} $_toCurrency'),
                _QuoteRow('You send', _quote!.fromAmountMinor > 0
                    ? '₦${(_quote!.fromAmountMinor / 100).toStringAsFixed(0)}'
                    : '—'),
                _QuoteRow('Fee', _quote!.feeFormatted),
                const Divider(color: Colors.white24, height: 20),
                _QuoteRow('Recipient gets', _quote!.toAmountFormatted, highlight: true),
                _QuoteRow('Rate valid for', '${_quote!.expiresInSeconds}s'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _converting ? null : _convert,
              style: ElevatedButton.styleFrom(
                backgroundColor: WaziColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _converting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Convert Now', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
            ),
          ),
        ],

        if (_success != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(_success!, style: WaziText.inter(size: 13, color: Colors.greenAccent))),
              ],
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WaziText.inter(size: 13, color: WaziColors.textAt(0.55))),
        Text(value,
            style: highlight
                ? WaziText.grotesk(size: 20, weight: FontWeight.w700, color: WaziColors.teal)
                : WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
      ],
    ),
  );
}

/// "Pay a Bill Back Home" — existing diaspora direct-to-obligation flow.
class _PayBillForm extends StatelessWidget {
  const _PayBillForm({required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return PaymentPickerForm(
      appState: appState,
      pickerLabel: 'Institution',
      infoBanner: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pay a school, hospital, or utility bill back home directly, in Naira — no separate FX transfer, no handing cash to someone else.',
                style: WaziText.inter(size: 12, color: Colors.blue.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ),
      ),
      loadOptions: () async {
        final all = await appState.institutionsApi.listInstitutions();
        final obligations = all.where((i) => i.category != 'telecom').toList();
        return obligations.map((i) => PickerOption(id: i.institutionId, label: i.name, subtitle: i.obligationLabel)).toList();
      },
      onSubmit: (name, amountMinor) => appState.initiateInstitutionPayment(name, amountMinor),
      submitLabel: 'Pay Now',
    );
  }
}
