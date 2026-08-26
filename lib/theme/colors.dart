import 'package:flutter/material.dart';

/// Design tokens straight from Wazi.dc.html. Kept as flat static consts
/// rather than a ThemeExtension — this app has one fixed dark palette, no
/// light/dark or brand-swap requirement, so the extra indirection isn't
/// earning its keep yet.
abstract class WaziColors {
  static const bg = Color(0xFF0A0E1D);
  static const bgOuter = Color(0xFF070A15);
  static const card = Color(0xFF12162B);
  static const text = Color(0xFFF4F1EA);
  static const gold = Color(0xFFE8A94C);
  static const goldDark = Color(0xFFC9832B);
  static const teal = Color(0xFF5EEAD4);
  static const scanBg = Color(0xFF06080F);

  static Color textAt(double opacity) => text.withValues(alpha: opacity);
  static Color goldAt(double opacity) => gold.withValues(alpha: opacity);
  static Color tealAt(double opacity) => teal.withValues(alpha: opacity);
}
