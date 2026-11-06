import 'package:flutter/material.dart';

import '../api/support_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'general';
  bool _submitting = false;
  String? _error;
  String? _success;

  static const _categories = [
    ('general', 'General', Icons.help_outline_rounded, Colors.white70),
    ('payment', 'Payment Issue', Icons.payment_rounded, Colors.greenAccent),
    ('account', 'Account', Icons.person_outline_rounded, Colors.blueAccent),
    ('security', 'Security', Icons.security_rounded, Colors.redAccent),
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  List<SupportTicket> _history = [];
  bool _loadingHistory = true;

  Future<void> _loadHistory() async {
    final userId = widget.appState.userId;
    if (userId == null) { setState(() => _loadingHistory = false); return; }
    try {
      final tickets = await widget.appState.supportApi.listTickets(userId);
      if (!mounted) return;
      setState(() { _history = tickets; _loadingHistory = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _submit() async {
    final userId = widget.appState.userId;
    if (userId == null) return;
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      setState(() => _error = 'Please fill in both fields.');
      return;
    }
    setState(() { _submitting = true; _error = null; _success = null; });
    try {
      final ticket = await widget.appState.supportApi.createTicket(
        userId: userId,
        subject: subject,
        message: message,
        category: _category,
      );
      _subjectController.clear();
      _messageController.clear();
      await _loadHistory();
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _success = ticket.autoReply;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Failed to submit. Please try again.'; _submitting = false; });
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
                    onTap: () => widget.appState.go(AppScreen.settings),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Customer Service', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chips
                    Text('Category', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((entry) {
                        final (key, label, icon, color) = entry;
                        final selected = _category == key;
                        return GestureDetector(
                          onTap: () => setState(() => _category = key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 16, color: selected ? color : WaziColors.textAt(0.5)),
                                const SizedBox(width: 6),
                                Text(label, style: WaziText.inter(size: 13, weight: FontWeight.w500,
                                    color: selected ? color : Colors.white)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Subject
                    Text('Subject', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 8),
                    _TextField(controller: _subjectController, hint: 'Brief summary of your issue'),

                    const SizedBox(height: 16),

                    // Message
                    Text('Message', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 8),
                    _TextField(controller: _messageController, hint: 'Describe your issue in detail', maxLines: 4),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ],

                    const SizedBox(height: 20),

                    // Submit button
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WaziColors.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Submit Ticket', style: WaziText.inter(size: 15, weight: FontWeight.w600)),
                      ),
                    ),

                    // Success message
                    if (_success != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_success!, style: WaziText.inter(size: 13, color: Colors.greenAccent))),
                          ],
                        ),
                      ),
                    ],

                    // Previous tickets
                    if (!_loadingHistory && _history.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text('Previous Tickets', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                      const SizedBox(height: 14),
                      ..._history.map((t) => _TicketCard(ticket: t)),
                    ] else if (!_loadingHistory && _history.isEmpty && _success == null) ...[
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.support_agent_rounded, size: 40, color: WaziColors.textAt(0.2)),
                            const SizedBox(height: 12),
                            Text('No previous tickets', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.4))),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Hotline
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: WaziColors.teal.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: WaziColors.teal.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_in_talk_rounded, color: WaziColors.teal, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('24/7 Hotline', style: WaziText.inter(size: 14, weight: FontWeight.w600, color: WaziColors.teal)),
                                Text('0700-WAZI-HELP (0700-9294-4357)', style: WaziText.inter(size: 13, color: WaziColors.teal.withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _TextField extends StatelessWidget {
  const _TextField({required this.controller, required this.hint, this.maxLines = 1});
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 0),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: WaziText.inter(size: 15, color: Colors.white),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: WaziText.inter(size: 15, color: WaziColors.textAt(0.35)),
        isDense: maxLines == 1,
        contentPadding: maxLines == 1 ? const EdgeInsets.symmetric(vertical: 14) : null,
      ),
    ),
  );
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: WaziColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(ticket.subject, style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ticket.status == 'open' ? WaziColors.gold.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ticket.status == 'open' ? 'Open' : 'Resolved',
                style: WaziText.inter(size: 11, weight: FontWeight.w600,
                    color: ticket.status == 'open' ? WaziColors.gold : Colors.greenAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(ticket.message, style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5)), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Text('#${ticket.ticketId.substring(4, 8).toUpperCase()} • ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
            style: WaziText.inter(size: 11, color: WaziColors.textAt(0.4))),
      ],
    ),
  );
}
