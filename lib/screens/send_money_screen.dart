import 'package:flutter/material.dart';

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
          decoration: const InputDecoration(hintText: 'Full name', hintStyle: TextStyle(color: Colors.white38)),
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
                    Row(
                      children: [
                        Expanded(child: _buildTab(title: 'To Wazi Account', active: !_toBankAccount, onTap: () => setState(() => _toBankAccount = false))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTab(title: 'To Bank Account', active: _toBankAccount, onTap: () => setState(() => _toBankAccount = true))),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (_toBankAccount)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Bank transfers aren't available in this demo yet — every transfer here moves between Wazi accounts. Try \"To Wazi Account\" instead.",
                                style: WaziText.inter(size: 13, color: WaziColors.textAt(0.6)),
                              ),
                            ),
                          ],
                        ),
                      )
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
            style: WaziText.inter(size: 13.5, weight: active ? FontWeight.w600 : FontWeight.w500, color: active ? Colors.white : WaziColors.textAt(0.5)),
          ),
        ),
      ),
    );
  }
}
