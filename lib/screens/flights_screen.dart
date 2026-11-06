import 'package:flutter/material.dart';

import '../api/lifestyle_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  List<FlightOut> _results = [];
  bool _searching = false;
  String? _error;
  final _fromController = TextEditingController(text: 'LOS');
  final _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() { _searching = true; _error = null; });
    try {
      final flights = await widget.appState.lifestyleApi.searchFlights(
        fromCode: _fromController.text.trim().toUpperCase(),
        toCode: _toController.text.trim().isNotEmpty ? _toController.text.trim().toUpperCase() : null,
      );
      if (!mounted) return;
      setState(() { _results = flights; _searching = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Search failed.'; _searching = false; });
    }
  }

  Future<void> _book(FlightOut flight) async {
    final userId = widget.appState.userId;
    if (userId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WaziColors.card,
        title: Text('Book Flight', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${flight.airline}', style: WaziText.inter(size: 16, color: Colors.white, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('${flight.fromCity} → ${flight.toCity}', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.6))),
          Text('${flight.departTime} - ${flight.arriveTime} (${flight.duration})', style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5))),
          const SizedBox(height: 12),
          Text(flight.priceFormatted, style: WaziText.grotesk(size: 22, weight: FontWeight.w700, color: WaziColors.gold)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: WaziColors.gold, foregroundColor: Colors.black),
            child: const Text('Book & Pay'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final result = await widget.appState.lifestyleApi.bookFlight(userId, flight.flightId);
      await widget.appState.refreshBalance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Flight booked! ${result.route} — ${result.priceFormatted}'),
        backgroundColor: Colors.green.shade800,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red.shade800));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => widget.appState.go(AppScreen.services),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
            ),
            const SizedBox(width: 16),
            Text('Flights', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(children: [
            Expanded(child: _AirportField(_fromController, 'From', Icons.flight_takeoff_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _AirportField(_toController, 'To', Icons.flight_land_rounded)),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: _searching ? null : _search,
              style: ElevatedButton.styleFrom(backgroundColor: WaziColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _searching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Search Flights', style: WaziText.inter(size: 15, weight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _searching
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
            : _results.isEmpty
              ? Center(child: Text('Search for flights to see results', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.3))))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _results.length,
                  itemBuilder: (_, i) => _FlightCard(flight: _results[i], onTap: () => _book(_results[i])),
                )),
      ])),
    );
  }
}

class _AirportField extends StatelessWidget {
  const _AirportField(this.controller, this.label, this.icon);
  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: Row(children: [
      Icon(icon, color: WaziColors.textAt(0.5), size: 20),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: controller, textCapitalization: TextCapitalization.characters,
        style: WaziText.grotesk(size: 18, weight: FontWeight.w700, color: Colors.white),
        decoration: InputDecoration(border: InputBorder.none, hintText: label, hintStyle: WaziText.inter(size: 13, color: WaziColors.textAt(0.4)), isDense: true),
      )),
    ]),
  );
}

class _FlightCard extends StatelessWidget {
  const _FlightCard({required this.flight, required this.onTap});
  final FlightOut flight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WaziColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(flight.fromCode, style: WaziText.grotesk(size: 18, weight: FontWeight.w700, color: Colors.white)),
            Icon(Icons.flight_rounded, size: 16, color: WaziColors.textAt(0.4)),
            Text(flight.toCode, style: WaziText.grotesk(size: 18, weight: FontWeight.w700, color: Colors.white)),
          ]),
          const SizedBox(height: 4),
          Text(flight.airline, style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5))),
          const SizedBox(height: 4),
          Text('${flight.departTime} - ${flight.arriveTime} (${flight.duration})${flight.stops > 0 ? " ${flight.stops} stop" : ""}',
            style: WaziText.inter(size: 12, color: WaziColors.textAt(0.4))),
        ])),
        Text(flight.priceFormatted, style: WaziText.grotesk(size: 16, weight: FontWeight.w700, color: WaziColors.gold)),
      ]),
    ),
  );
}
