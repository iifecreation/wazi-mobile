import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'sheet_common.dart';

const _items = [
  (WaziColors.gold, '₦312,400 sent to Amara Okafor', 'Voice transfer · 2 min ago'),
  (WaziColors.teal, 'Rate alert: ₦1,562 / \$1', 'Best in 9 days · 1 h ago'),
  (Color(0x40F4F1EA), 'Transport spend is 22% up', 'Monthly insight · yesterday'),
];

class NotifSheet extends StatelessWidget {
  const NotifSheet({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      accent: WaziColors.textAt(.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: WaziText.grotesk(size: 21, weight: FontWeight.w600)),
          const SizedBox(height: 18),
          Column(
            children: _items.asMap().entries.map((e) {
              final isLast = e.key == _items.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.07)))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: e.value.$1)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.$2, style: WaziText.inter(size: 14.5)),
                          Text(e.value.$3, style: WaziText.inter(size: 12, color: WaziColors.textAt(.42))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: appState.dismiss,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: WaziColors.textAt(.18)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Close', style: WaziText.grotesk(size: 15, weight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
