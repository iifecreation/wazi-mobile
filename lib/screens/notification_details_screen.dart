import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final notif = appState.selectedNotification;
    if (notif == null) {
      return const SizedBox.shrink(); // Safety fallback
    }

    final String type = notif['type'] as String;
    
    IconData icon;
    Color iconColor;
    if (type == 'transfer') {
      icon = Icons.swap_horiz_rounded;
      iconColor = WaziColors.teal;
    } else if (type == 'security') {
      icon = Icons.shield_outlined;
      iconColor = WaziColors.gold;
    } else {
      icon = Icons.info_outline_rounded;
      iconColor = Colors.white54;
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.notifications),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(icon, color: iconColor, size: 36),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    notif['title'],
                    style: WaziText.grotesk(size: 28, weight: FontWeight.w600, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notif['time'],
                    style: WaziText.inter(size: 14, color: WaziColors.textAt(0.5)),
                  ),
                  const SizedBox(height: 32),
                  
                  // Message Body
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      notif['body'],
                      style: WaziText.inter(size: 16, color: WaziColors.textAt(0.8), height: 1.5),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Call to Action
                  if (type == 'transfer')
                    GestureDetector(
                      onTap: () {
                        appState.go(AppScreen.insights);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: WaziColors.teal,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text('View Transaction', style: WaziText.inter(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
                        ),
                      ),
                    ),
                    
                  if (type == 'security')
                    GestureDetector(
                      onTap: () {
                        appState.go(AppScreen.settings);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: WaziColors.gold,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text('Review Security Settings', style: WaziText.inter(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
