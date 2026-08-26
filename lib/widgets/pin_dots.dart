import 'package:flutter/material.dart';

import '../theme/colors.dart';

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, this.filled = true});

  /// Number of digits entered (0-4).
  final int length;

  /// The static "already set" display on the auth screen always shows 4
  /// filled dots; the live PIN sheet fills them as the user types.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final on = filled || i < length;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? WaziColors.gold : Colors.transparent,
            border: Border.all(color: on ? WaziColors.gold : WaziColors.textAt(.3)),
          ),
        );
      }),
    );
  }
}
