import 'package:flutter/material.dart';

import 'colors.dart';

/// Space Grotesk for headings/numbers/buttons, Inter for body text — same
/// split as the design. Both are bundled as local variable-font assets (see
/// pubspec.yaml) rather than fetched at runtime.
abstract class WaziText {
  static TextStyle grotesk({
    required double size,
    FontWeight weight = FontWeight.w600,
    double? letterSpacing,
    double? height,
    Color color = WaziColors.text,
  }) => TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );

  static TextStyle inter({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color color = WaziColors.text,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );
}
