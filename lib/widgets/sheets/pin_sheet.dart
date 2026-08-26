import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../pin_dots.dart';
import 'sheet_common.dart';

const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

class PinSheet extends StatelessWidget {
  const PinSheet({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return SheetContainer(
          accent: WaziColors.textAt(.12),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
          child: Column(
            children: [
              Text('Enter your PIN', style: WaziText.grotesk(size: 19, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text("Voice proved it's you. PIN moves the money.", style: WaziText.inter(size: 13, color: WaziColors.textAt(.5))),
              const SizedBox(height: 20),
              if (appState.busy)
                const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
              else
                PinDots(length: appState.pin.length, filled: false),
              if (appState.paymentError != null) ...[
                const SizedBox(height: 12),
                Text(appState.paymentError!, style: WaziText.inter(size: 12.5, color: WaziColors.gold), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: _keys.map((k) {
                  return GestureDetector(
                    onTap: (k.isEmpty || appState.busy) ? null : () => appState.keyPress(k),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: k.isEmpty ? Colors.transparent : WaziColors.textAt(.06),
                      ),
                      alignment: Alignment.center,
                      child: Text(k, style: WaziText.grotesk(size: 22, weight: FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: appState.busy ? null : appState.dismiss,
                child: Text('Cancel', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5))),
              ),
            ],
          ),
        );
      },
    );
  }
}
