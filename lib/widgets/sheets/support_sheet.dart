import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'sheet_common.dart';

class SupportSheet extends StatelessWidget {
  const SupportSheet({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      accent: WaziColors.textAt(.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need a human?', style: WaziText.grotesk(size: 21, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Agents answer in English and Pidgin, 24/7. Say "talk to support" any time.',
            style: WaziText.inter(size: 14, color: WaziColors.textAt(.55)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: appState.dismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: WaziColors.gold,
                foregroundColor: WaziColors.bg,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Call support', style: WaziText.grotesk(size: 15, weight: FontWeight.w600, color: WaziColors.bg)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: appState.toChat,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: WaziColors.textAt(.18)),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Chat instead', style: WaziText.grotesk(size: 15, weight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: appState.dismiss,
              child: Text('Report a transaction', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5))),
            ),
          ),
        ],
      ),
    );
  }
}
