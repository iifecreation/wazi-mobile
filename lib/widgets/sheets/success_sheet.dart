import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../pulse_ring.dart';
import 'sheet_common.dart';

class SuccessSheet extends StatefulWidget {
  const SuccessSheet({super.key, required this.appState});

  final AppState appState;

  @override
  State<SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<SuccessSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.appState.lastPaymentResult;
    return SheetContainer(
      accent: WaziColors.goldAt(.35),
      padding: const EdgeInsets.fromLTRB(22, 32, 22, 30),
      child: Column(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PulseRing(color: WaziColors.goldAt(.6), size: 96, duration: const Duration(milliseconds: 2000), maxScale: 1.3, startOpacity: 1.0),
                ScaleTransition(
                  scale: CurvedAnimation(parent: _pop, curve: const Cubic(.2, 1.1, .3, 1)),
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.gold),
                    child: const Icon(Icons.check_rounded, color: WaziColors.bg, size: 34),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('${result?.amountFormatted ?? ''} sent', style: WaziText.grotesk(size: 28, weight: FontWeight.w600, letterSpacing: -0.6)),
          const SizedBox(height: 8),
          Text(
            '${result?.recipientName ?? ''} has it. ${result?.newBalanceFormatted != null ? "New balance ${result!.newBalanceFormatted}." : ""}',
            style: WaziText.inter(size: 14.5, color: WaziColors.textAt(.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.appState.toTyping,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: WaziColors.textAt(.18)),
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('See receipt', style: WaziText.grotesk(size: 15, weight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.appState.finishSuccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WaziColors.gold,
                    foregroundColor: WaziColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Done', style: WaziText.grotesk(size: 15, weight: FontWeight.w600, color: WaziColors.bg)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
