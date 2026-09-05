import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// One selectable option in a PaymentPickerForm — a saved contact, a
/// verified institution, or a telecom provider. `subtitle` is optional
/// context (e.g. an institution's obligation label).
class PickerOption {
  const PickerOption({required this.id, required this.label, this.subtitle});
  final String id;
  final String label;
  final String? subtitle;
}

/// Shared "pick who/what, type an amount, submit" form behind
/// send_money/airtime/electricity/cable_tv/international — every one of
/// these ends up calling one of AppState's initiate*Payment methods, which
/// all drive the same real confirm+PIN sheet already used by voice and by
/// the barcode scanner. This widget only builds the picker; it never talks
/// to the server directly.
class PaymentPickerForm extends StatefulWidget {
  const PaymentPickerForm({
    super.key,
    required this.appState,
    required this.pickerLabel,
    required this.loadOptions,
    required this.onSubmit,
    required this.submitLabel,
    this.onAddNew,
    this.addNewLabel,
    this.infoBanner,
  });

  final AppState appState;
  final String pickerLabel;
  final Future<List<PickerOption>> Function() loadOptions;
  final Future<bool> Function(String selectedLabel, int amountMinor) onSubmit;
  final String submitLabel;
  final Future<PickerOption?> Function(BuildContext context)? onAddNew;
  final String? addNewLabel;
  final Widget? infoBanner;

  @override
  State<PaymentPickerForm> createState() => _PaymentPickerFormState();
}

class _PaymentPickerFormState extends State<PaymentPickerForm> {
  bool _loadingOptions = true;
  String? _loadError;
  List<PickerOption> _options = [];
  PickerOption? _selected;
  final _amountController = TextEditingController();

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
    setState(() => _loadingOptions = true);
    try {
      final options = await widget.loadOptions();
      if (!mounted) return;
      setState(() {
        _options = options;
        _loadingOptions = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = "Couldn't load options";
        _loadingOptions = false;
      });
    }
  }

  Future<void> _addNew() async {
    final added = await widget.onAddNew?.call(context);
    if (added == null) return;
    setState(() {
      _options = [..._options, added];
      _selected = added;
    });
  }

  Future<void> _submit() async {
    final selected = _selected;
    final naira = int.tryParse(_amountController.text.trim());
    if (selected == null || naira == null || naira <= 0) return;
    final ok = await widget.onSubmit(selected.label, naira * 100);
    if (ok && mounted) {
      _amountController.clear();
      setState(() => _selected = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.infoBanner != null) ...[widget.infoBanner!, const SizedBox(height: 24)],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.pickerLabel, style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                if (widget.onAddNew != null)
                  GestureDetector(
                    onTap: _addNew,
                    child: Text(
                      widget.addNewLabel ?? '+ Add new',
                      style: WaziText.inter(size: 13, weight: FontWeight.w600, color: WaziColors.gold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loadingOptions)
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator())
            else if (_loadError != null)
              Text(_loadError!, style: const TextStyle(color: Colors.redAccent))
            else if (_options.isEmpty)
              Text(
                widget.onAddNew != null ? 'Nothing here yet. Tap "+ Add new" to create one.' : 'Nothing here yet.',
                style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5)),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _options.map((o) {
                  final isSelected = _selected?.id == o.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = o),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? WaziColors.gold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: isSelected ? WaziColors.gold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        o.label,
                        style: WaziText.inter(size: 13.5, weight: FontWeight.w500, color: isSelected ? WaziColors.gold : Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),
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
                style: WaziText.grotesk(size: 24, weight: FontWeight.w600, color: Colors.white),
                decoration: InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: WaziText.grotesk(size: 24, color: WaziColors.textAt(0.3))),
              ),
            ),
            if (widget.appState.error != null) ...[
              const SizedBox(height: 16),
              Text(widget.appState.error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (widget.appState.busy || _selected == null) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WaziColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: widget.appState.busy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(widget.submitLabel, style: WaziText.inter(size: 16, weight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }
}
