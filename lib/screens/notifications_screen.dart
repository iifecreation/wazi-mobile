import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

// Mock data for notifications
final List<Map<String, dynamic>> _mockNotifications = [
  {
    'id': '1',
    'title': 'Transfer Successful',
    'body': 'Your transfer of ₦15,000 to John Doe was successful.',
    'time': '2m ago',
    'type': 'transfer',
    'unread': true,
  },
  {
    'id': '2',
    'title': 'Security Alert',
    'body': 'A new device (iPhone 14) logged into your account.',
    'time': '1h ago',
    'type': 'security',
    'unread': true,
  },
  {
    'id': '3',
    'title': 'System Update',
    'body': 'Wazi will undergo scheduled maintenance tonight at 2 AM.',
    'time': 'Yesterday',
    'type': 'system',
    'unread': false,
  },
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => appState.go(AppScreen.dashboard),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                Text('Notifications', style: WaziText.grotesk(size: 24, weight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _mockNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final notif = _mockNotifications[index];
                return _NotificationCard(
                  notif: notif,
                  onTap: () => appState.openNotificationDetails(notif),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notif, required this.onTap});

  final Map<String, dynamic> notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = notif['unread'] == true;
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: unread ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: unread ? WaziColors.teal.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif['title'],
                          style: WaziText.inter(size: 15, weight: unread ? FontWeight.w600 : FontWeight.w500, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(notif['time'], style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif['body'],
                    style: WaziText.inter(size: 14, color: unread ? WaziColors.textAt(0.8) : WaziColors.textAt(0.5)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
