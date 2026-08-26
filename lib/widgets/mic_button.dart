import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'pulse_ring.dart';

/// The big center mic button on the home screen: gold when idle, teal
/// gradient + three staggered pulse rings when listening. Also reused
/// (smaller) on the insights and scan screens.
class MicButton extends StatelessWidget {
  const MicButton({
    super.key,
    required this.listening,
    required this.onTap,
    this.size = 88,
    this.iconSize = 30,
  });

  final bool listening;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 22,
      height: size + 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (listening) ...[
            PulseRing(
              color: WaziColors.tealAt(.8),
              size: size,
              duration: const Duration(milliseconds: 2100),
              strokeWidth: 1.5,
            ),
            PulseRing(
              color: WaziColors.tealAt(.6),
              size: size,
              duration: const Duration(milliseconds: 2100),
              delay: const Duration(milliseconds: 700),
              strokeWidth: 1.5,
            ),
            PulseRing(
              color: WaziColors.goldAt(.5),
              size: size,
              duration: const Duration(milliseconds: 2100),
              delay: const Duration(milliseconds: 1400),
              strokeWidth: 1.5,
            ),
          ],
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: listening
                      ? const [Color(0xFF5EEAD4), Color(0xFF2FBBA6)]
                      : const [WaziColors.gold, WaziColors.goldDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (listening ? WaziColors.teal : WaziColors.gold).withValues(alpha: .32),
                    blurRadius: 46,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Icon(Icons.mic_rounded, color: WaziColors.bg, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}
