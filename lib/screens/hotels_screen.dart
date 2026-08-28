import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key, required this.appState});

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
                  Text('Hotels', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Where are you going?', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: TextField(
                        style: WaziText.inter(size: 16, color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'City, Airport, or Hotel',
                          hintStyle: WaziText.inter(size: 16, color: WaziColors.textAt(0.3)),
                          icon: Icon(Icons.search_rounded, color: WaziColors.textAt(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Check-in', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, color: WaziColors.textAt(0.5), size: 20),
                                    const SizedBox(width: 8),
                                    Text('Aug 28', style: WaziText.inter(size: 14, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Check-out', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, color: WaziColors.textAt(0.5), size: 20),
                                    const SizedBox(width: 8),
                                    Text('Sep 02', style: WaziText.inter(size: 14, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Guests & Rooms', style: WaziText.inter(size: 14, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_rounded, color: WaziColors.textAt(0.5), size: 20),
                          const SizedBox(width: 8),
                          Text('2 Adults, 1 Room', style: WaziText.inter(size: 14, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WaziColors.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Search Hotels', style: WaziText.inter(size: 16, weight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text('Popular Destinations', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDestination(name: 'Dubai', imageColor: Colors.amber, hotels: '4,200+ Hotels'),
                          const SizedBox(width: 16),
                          _buildDestination(name: 'London', imageColor: Colors.blueGrey, hotels: '2,800+ Hotels'),
                          const SizedBox(width: 16),
                          _buildDestination(name: 'Paris', imageColor: Colors.pink, hotels: '3,100+ Hotels'),
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

  Widget _buildDestination({required String name, required Color imageColor, required String hotels}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: imageColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: imageColor.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Icon(Icons.landscape_rounded, color: imageColor, size: 48),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 4),
        Text(hotels, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
      ],
    );
  }
}
