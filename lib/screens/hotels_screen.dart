import 'package:flutter/material.dart';

import '../api/lifestyle_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  List<HotelOut> _results = [];
  bool _searching = false;
  String? _error;
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() { _searching = true; _error = null; });
    try {
      final hotels = await widget.appState.lifestyleApi.searchHotels(
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      );
      if (!mounted) return;
      setState(() { _results = hotels; _searching = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Search failed.'; _searching = false; });
    }
  }

  Future<void> _book(HotelOut hotel) async {
    final userId = widget.appState.userId;
    if (userId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WaziColors.card,
        title: Text('Book Hotel', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hotel.name, style: WaziText.inter(size: 16, color: Colors.white, weight: FontWeight.w600)),
          Text('${hotel.city} • ${List.filled(hotel.starRating, '★').join()}', style: WaziText.inter(size: 13, color: WaziColors.textAt(0.5))),
          const SizedBox(height: 12),
          Text('1 night at ${hotel.priceFormatted}', style: WaziText.grotesk(size: 18, weight: FontWeight.w700, color: WaziColors.gold)),
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
      final result = await widget.appState.lifestyleApi.bookHotel(userId, hotel.hotelId, 1);
      await widget.appState.refreshBalance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Hotel booked! ${result.route} — ${result.priceFormatted}'),
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
            Text('Hotels', style: WaziText.grotesk(size: 20, weight: FontWeight.w600)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(children: [
              Icon(Icons.search_rounded, color: WaziColors.textAt(0.5), size: 20),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: _cityController,
                style: WaziText.inter(size: 15, color: Colors.white),
                decoration: InputDecoration(border: InputBorder.none, hintText: 'City (e.g. Lagos)', hintStyle: WaziText.inter(size: 15, color: WaziColors.textAt(0.35)), isDense: true),
              )),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: _searching ? null : _search,
              style: ElevatedButton.styleFrom(backgroundColor: WaziColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _searching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Search Hotels', style: WaziText.inter(size: 15, weight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _searching
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
            : _results.isEmpty
              ? Center(child: Text('Search to find hotels', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.3))))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _results.length,
                  itemBuilder: (_, i) => _HotelCard(hotel: _results[i], onTap: () => _book(_results[i])),
                )),
      ])),
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.hotel, required this.onTap});
  final HotelOut hotel;
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
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: WaziColors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.hotel_rounded, color: WaziColors.teal, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hotel.name, style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${hotel.city} • ${List.filled(hotel.starRating, '★').join()}', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
          const SizedBox(height: 6),
          Wrap(spacing: 4, runSpacing: 4, children: hotel.amenities.take(3).map((a) =>
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
              child: Text(a, style: WaziText.inter(size: 10, color: WaziColors.textAt(0.5))))).toList()),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(hotel.priceFormatted, style: WaziText.grotesk(size: 15, weight: FontWeight.w700, color: WaziColors.gold)),
          Text('/ night', style: WaziText.inter(size: 11, color: WaziColors.textAt(0.4))),
        ]),
      ]),
    ),
  );
}
