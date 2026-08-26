import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'sheet_common.dart';

class PrivacySheet extends StatelessWidget {
  const PrivacySheet({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      accent: WaziColors.tealAt(.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle, color: WaziColors.tealAt(.14)),
                child: const Icon(Icons.hearing_rounded, size: 17, color: WaziColors.teal),
              ),
              const SizedBox(width: 10),
              Text('NO EARPIECE DETECTED', style: WaziText.inter(size: 11.5, color: WaziColors.teal, letterSpacing: 1.7)),
            ],
          ),
          const SizedBox(height: 14),
          Text('Are you somewhere private?', style: WaziText.grotesk(size: 25, weight: FontWeight.w600, height: 1.15, letterSpacing: -0.4)),
          const SizedBox(height: 10),
          Text(
            'You asked for your balance. I can say it out loud, or keep it to the screen so nobody else hears it.',
            style: WaziText.inter(size: 14.5, color: WaziColors.textAt(.6)),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: appState.privacyAloud,
              style: ElevatedButton.styleFrom(
                backgroundColor: WaziColors.teal,
                foregroundColor: WaziColors.bg,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Yes — say it aloud', style: WaziText.grotesk(size: 15.5, weight: FontWeight.w600, color: WaziColors.bg)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: appState.privacyScreen,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: WaziColors.textAt(.2)),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Show it on screen only', style: WaziText.grotesk(size: 15.5, weight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Turn this check off in Settings → Voice & AI.',
            textAlign: TextAlign.center,
            style: WaziText.inter(size: 12, color: WaziColors.textAt(.4)),
          ),
        ],
      ),
    );
  }
}
