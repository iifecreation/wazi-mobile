import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Shared chrome for every bottom sheet: rounded top corners, a colored top
/// border matching the sheet's accent, and the small drag-handle bar.
class SheetContainer extends StatelessWidget {
  const SheetContainer({
    super.key,
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.fromLTRB(22, 26, 22, 30),
  });

  final Widget child;
  final Color accent;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: WaziColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: accent)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: WaziColors.textAt(.18)),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
