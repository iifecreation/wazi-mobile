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
    required this.soundLevel,
    this.onTap,
    this.size = 88,
    this.iconSize = 30,
  });

  final bool listening;
  final double soundLevel;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    // Normalizing soundLevel (usually -50 to 50) to a positive scale modifier
    final double normalizedSound = (soundLevel > 0 ? soundLevel : 0) / 20.0;
    final double dynamicScale = 1.0 + (listening ? (normalizedSound.clamp(0.0, 1.5) * 0.4) : 0.0);

    return SizedBox(
      width: size + 22,
      height: size + 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (listening)
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: size * dynamicScale * 1.3,
              height: size * dynamicScale * 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WaziColors.teal.withValues(alpha: 0.2),
              ),
            ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: size * dynamicScale,
              height: size * dynamicScale,
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
