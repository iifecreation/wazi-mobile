import 'package:flutter/material.dart';

import '../api/transfers_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/payment_picker_form.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  bool _toBankAccount = false;

  Future<PickerOption?> _promptAddContact(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WaziColors.card,
        title: Text('Add a contact', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: WaziText.inter(size: 16, color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Full name',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return null;
    final userId = widget.appState.userId;
    if (userId == null) return null;
    try {
      final contact = await widget.appState.contactsApi.addContact(userId, name);
      return PickerOption(id: contact.contactId, label: contact.name);
    } catch (_) {
      return null;
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
                  Text('Send Money', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
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
                        Expanded(child: _buildTab(title: 'To Wazi Contact', active: !_toBankAccount, onTap: () => setState(() => _toBankAccount = false))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTab(title: 'To Bank Account', active: _toBankAccount, onTap: () => setState(() => _toBankAccount = true))),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (_toBankAccount)
                      _BankTransferForm(appState: widget.appState)
                    else
                      PaymentPickerForm(
                        appState: widget.appState,
                        pickerLabel: 'Send to',
                        addNewLabel: '+ Add contact',
                        loadOptions: () async {
                          final userId = widget.appState.userId;
                          if (userId == null) return [];
                          final contacts = await widget.appState.contactsApi.listContacts(userId);
                          return contacts.map((c) => PickerOption(id: c.contactId, label: c.name)).toList();
                        },
                        onAddNew: _promptAddContact,
                        onSubmit: (name, amountMinor) => widget.appState.initiateContactPayment(name, amountMinor),
                        submitLabel: 'Send Money',
                      ),
                  ],
                ),
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
              size: 13.5,
              weight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? Colors.white : WaziColors.textAt(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bank transfer form — account number + bank picker + amount + name lookup.
class _BankTransferForm extends StatefulWidget {
  const _BankTransferForm({required this.appState});
  final AppState appState;

  @override
  State<_BankTransferForm> createState() => _BankTransferFormState();
}

class _BankTransferFormState extends State<_BankTransferForm> {
  List<BankInfo> _banks = [];
  BankInfo? _selectedBank;
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  String? _beneficiaryName;
  bool _lookingUp = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await widget.appState.transfersApi.listBanks();
      if (!mounted) return;
      setState(() => _banks = banks);
    } catch (_) {}
  }

  Future<void> _lookupName() async {
    final acct = _accountController.text.trim();
    final bank = _selectedBank;
    if (acct.length != 10 || bank == null) return;
    setState(() { _lookingUp = true; _beneficiaryName = null; _error = null; });
    try {
      final userId = widget.appState.userId ?? 'anon';
      final res = await widget.appState.transfersApi.nameEnquiry(
        userId: userId, accountNumber: acct, bankCode: bank.code,
      );
      if (!mounted) return;
      setState(() { _beneficiaryName = res.beneficiaryName; _lookingUp = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _lookingUp = false; _error = 'Could not verify account. Check the number and try again.'; });
    }
  }

  Future<void> _submit() async {
    final acct = _accountController.text.trim();
    final bank = _selectedBank;
    final naira = int.tryParse(_amountController.text.trim());
    if (acct.isEmpty || bank == null || naira == null || naira <= 0) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    final result = await widget.appState.initiateTransfer(
      amountMinor: naira * 100,
      bankCode: bank.code,
      accountNumber: acct,
      narration: _narrationController.text.trim().isEmpty ? 'Transfer' : _narrationController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result != null) {
      _accountController.clear();
      _amountController.clear();
      _narrationController.clear();
      setState(() { _selectedBank = null; _beneficiaryName = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer of ${result.amountFormatted} to ${result.beneficiaryName} was successful!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } else {
      setState(() => _error = widget.appState.error ?? 'Transfer failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank picker
        Text('Bank', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _banks.isEmpty ? null : () => _showBankPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedBank?.name ?? (_banks.isEmpty ? 'Loading banks...' : 'Select a bank'),
                    style: WaziText.inter(size: 15,
                        color: _selectedBank != null ? Colors.white : WaziColors.textAt(0.4)),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Account number
        Text('Account Number', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
        const SizedBox(height: 8),
        _InputBox(
          controller: _accountController,
          hint: '10-digit NUBAN',
          keyboardType: TextInputType.number,
          maxLength: 10,
          onChanged: (v) {
            if (v.length == 10 && _selectedBank != null) _lookupName();
          },
        ),

        // Beneficiary name lookup result
        if (_lookingUp)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Looking up account...', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ]),
          )
        else if (_beneficiaryName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 8),
                Text(_beneficiaryName!, style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.greenAccent)),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // Amount
        Text('Amount (₦)', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
        const SizedBox(height: 8),
        _InputBox(controller: _amountController, hint: '0', keyboardType: TextInputType.number, large: true),
        const SizedBox(height: 4),
        Text('₦50 transfer fee applies', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.4))),
        const SizedBox(height: 20),

        // Narration
        Text('Narration (optional)', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
        const SizedBox(height: 8),
        _InputBox(controller: _narrationController, hint: 'What is this for?'),
        const SizedBox(height: 8),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Send Money', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  void _showBankPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: WaziColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final search = TextEditingController();
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _banks.where((b) =>
              b.name.toLowerCase().contains(search.text.toLowerCase())).toList();
            return Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: search,
                    onChanged: (_) => setModalState(() {}),
                    style: WaziText.inter(size: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search bank',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.07),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final bank = filtered[i];
                      return ListTile(
                        title: Text(bank.name, style: WaziText.inter(size: 14, color: Colors.white)),
                        subtitle: Text(bank.code, style: WaziText.inter(size: 12, color: Colors.white54)),
                        onTap: () {
                          setState(() => _selectedBank = bank);
                          Navigator.pop(context);
                          if (_accountController.text.length == 10) _lookupName();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.large = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool large;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        style: large
            ? WaziText.grotesk(size: 28, weight: FontWeight.w700, color: Colors.white)
            : WaziText.inter(size: 15, color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          counterText: '',
          hintStyle: large
              ? WaziText.grotesk(size: 28, color: WaziColors.textAt(0.3))
              : WaziText.inter(size: 15, color: WaziColors.textAt(0.35)),
          isDense: !large,
          contentPadding: EdgeInsets.symmetric(vertical: large ? 16 : 14),
        ),
      ),
    );
  }
}
