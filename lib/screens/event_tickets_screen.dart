import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class EventTicketsScreen extends StatelessWidget {
  const EventTicketsScreen({super.key, required this.appState});

  final AppState appState;

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
                    onTap: () => appState.go(AppScreen.services),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Event Tickets', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryTab(title: 'All Events', active: true),
                          const SizedBox(width: 12),
                          _buildCategoryTab(title: 'Music', active: false),
                          const SizedBox(width: 12),
                          _buildCategoryTab(title: 'Sports', active: false),
                          const SizedBox(width: 12),
                          _buildCategoryTab(title: 'Tech', active: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Trending Events', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    _buildEventCard(
                      title: 'Afro Nation Festival',
                      date: 'Oct 15 - Oct 17',
                      location: 'Eko Atlantic, Lagos',
                      price: '\$150',
                      color: Colors.orange,
                      icon: Icons.music_note_rounded,
                    ),
                    _buildEventCard(
                      title: 'Tech Safari Summit',
                      date: 'Nov 02',
                      location: 'KICC, Nairobi',
                      price: 'Free',
                      color: Colors.blue,
                      icon: Icons.computer_rounded,
                    ),
                    _buildEventCard(
                      title: 'Derby Match',
                      date: 'Aug 30',
                      location: 'National Stadium',
                      price: '\$25',
                      color: Colors.green,
                      icon: Icons.sports_soccer_rounded,
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

  Widget _buildCategoryTab({required String title, required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active ? WaziColors.gold : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? WaziColors.gold : Colors.white.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(
          title,
          style: WaziText.inter(
            size: 14,
            weight: FontWeight.w600,
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String location,
    required String price,
    required Color color,
    required IconData icon,
  }) {
    return Container(
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
            width: 64,
            height: 64,
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
                Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: WaziColors.textAt(0.5), size: 14),
                    const SizedBox(width: 4),
                    Text(date, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: WaziColors.textAt(0.5), size: 14),
                    const SizedBox(width: 4),
                    Text(location, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                  ],
                ),
              ],
            ),
          ),
          Text(price, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: WaziColors.gold)),
        ],
      ),
    );
  }
}
