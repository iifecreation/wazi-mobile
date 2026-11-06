import 'package:flutter/material.dart';

import '../api/events_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class EventTicketsScreen extends StatefulWidget {
  const EventTicketsScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<EventTicketsScreen> createState() => _EventTicketsScreenState();
}

class _EventTicketsScreenState extends State<EventTicketsScreen> {
  String _category = 'all';
  List<EventOut> _events = [];
  bool _loading = true;
  String? _error;
  String? _purchaseMsg;

  static const _categories = [
    ('all', 'All Events'),
    ('music', 'Music'),
    ('sports', 'Sports'),
    ('tech', 'Tech'),
    ('fashion', 'Fashion'),
  ];

  static const _categoryIcons = {
    'music': Icons.music_note_rounded,
    'sports': Icons.sports_soccer_rounded,
    'tech': Icons.computer_rounded,
    'fashion': Icons.checkroom_rounded,
  };

  static const _categoryColors = {
    'music': Colors.orange,
    'sports': Colors.green,
    'tech': Colors.blue,
    'fashion': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final events = await widget.appState.eventsApi.listEvents(
        category: _category == 'all' ? null : _category,
      );
      if (!mounted) return;
      setState(() { _events = events; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Could not load events.'; _loading = false; });
    }
  }

  Future<void> _purchase(EventOut event) async {
    final userId = widget.appState.userId;
    if (userId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WaziColors.card,
        title: Text('Buy Ticket', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: WaziText.inter(size: 16, color: Colors.white, weight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('${event.date} • ${event.location}', style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5))),
            const SizedBox(height: 12),
            Text('Price: ${event.priceFormatted}', style: WaziText.inter(size: 15, color: WaziColors.gold, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('1 ticket will be purchased from your Wazi balance.', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: WaziColors.gold, foregroundColor: Colors.black),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final result = await widget.appState.eventsApi.purchase(userId, event.eventId, 1);
      await widget.appState.refreshBalance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket purchased! ${result.eventTitle} — ${result.totalFormatted}'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e'), backgroundColor: Colors.red.shade800),
      );
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
                  Text('Event Tickets', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            // Category tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: _categories.map((entry) {
                  final (key, label) = entry;
                  final active = _category == key;
                  return GestureDetector(
                    onTap: () { setState(() => _category = key); _load(); },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? WaziColors.gold : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: active ? WaziColors.gold : Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        label,
                        style: WaziText.inter(size: 14, weight: FontWeight.w600,
                            color: active ? Colors.black : Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                  : _events.isEmpty
                    ? Center(child: Text('No events found', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.4))))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trending Events', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                            const SizedBox(height: 16),
                            ..._events.map((e) => _EventCard(event: e, onTap: () => _purchase(e))),
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

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onTap});
  final EventOut event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = _EventTicketsScreenState._categoryIcons[event.category] ?? Icons.event_rounded;
    final color = _EventTicketsScreenState._categoryColors[event.category] ?? WaziColors.gold;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.calendar_month_rounded, color: WaziColors.textAt(0.5), size: 14),
                    const SizedBox(width: 4),
                    Text(event.date, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_rounded, color: WaziColors.textAt(0.5), size: 14),
                    const SizedBox(width: 4),
                    Flexible(child: Text(event.location, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5)), overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(event.priceFormatted, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: WaziColors.gold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: WaziColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Buy', style: WaziText.inter(size: 11, weight: FontWeight.w600, color: WaziColors.gold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
