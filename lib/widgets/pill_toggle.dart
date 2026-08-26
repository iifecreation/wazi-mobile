import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// The settings screen's custom track+knob switch (gold when on).
class PillToggle extends StatelessWidget {
  const PillToggle({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: value ? WaziColors.gold : WaziColors.textAt(.16),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? WaziColors.bg : WaziColors.text,
          ),
        ),
      ),
    );
  }
}
