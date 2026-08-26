import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'sheet_common.dart';

class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final pending = appState.pendingPayment;
        return SheetContainer(
          accent: WaziColors.goldAt(.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CONFIRM PAYMENT', style: WaziText.inter(size: 11.5, color: WaziColors.gold, letterSpacing: 1.7)),
              const SizedBox(height: 8),
              Text(pending?.amountFormatted ?? '···', style: WaziText.grotesk(size: 34, weight: FontWeight.w600, letterSpacing: -1.0)),
              const SizedBox(height: 4),
              Text(pending?.replyText ?? '', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5))),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: WaziColors.textAt(.04)),
                child: Column(
                  children: [
                    _row('To', pending?.recipientName ?? '···', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: appState.busy ? null : appState.dismiss,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: WaziColors.textAt(.18)),
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text('Cancel', style: WaziText.grotesk(size: 15.5, weight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (appState.busy || pending == null) ? null : appState.confirmPendingPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WaziColors.gold,
                        foregroundColor: WaziColors.bg,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: appState.busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                          : Text('Confirm', style: WaziText.grotesk(size: 15.5, weight: FontWeight.w600, color: WaziColors.bg)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Your PIN is still required after this.',
                textAlign: TextAlign.center,
                style: WaziText.inter(size: 12, color: WaziColors.textAt(.4)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: WaziColors.textAt(.07)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.55))),
          Text(value, style: WaziText.inter(size: 14)),
        ],
      ),
    );
  }
}
