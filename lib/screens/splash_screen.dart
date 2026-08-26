import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pulse_ring.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.start();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WaziColors.bg,
      child: Stack(
        children: [
          Center(child: _content()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 54,
            child: Center(
              child: TextButton(
                onPressed: widget.appState.toOnboarding,
                child: Text(
                  'SKIP INTRO',
                  style: WaziText.inter(size: 12, color: WaziColors.textAt(.4), letterSpacing: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PulseRing(
                  color: WaziColors.teal,
                  size: 120,
                  duration: const Duration(milliseconds: 3200),
                  maxScale: 1.9,
                  startOpacity: .35,
                  strokeWidth: 1,
                ),
                PulseRing(
                  color: WaziColors.gold,
                  size: 120,
                  duration: const Duration(milliseconds: 3200),
                  delay: const Duration(milliseconds: 900),
                  maxScale: 1.9,
                  startOpacity: .35,
                  strokeWidth: 1,
                ),
                PulseRing(
                  color: WaziColors.textAt(.4),
                  size: 120,
                  duration: const Duration(milliseconds: 3200),
                  delay: const Duration(milliseconds: 1800),
                  maxScale: 1.9,
                  startOpacity: .35,
                  strokeWidth: 1,
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [WaziColors.gold, WaziColors.goldDark],
                    ),
                    boxShadow: [
                      BoxShadow(color: WaziColors.goldAt(.28), blurRadius: 50, offset: const Offset(0, 18)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text('w', style: WaziText.grotesk(size: 42, weight: FontWeight.w700, letterSpacing: -1.7, color: WaziColors.bg)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('wazi', style: WaziText.grotesk(size: 40, weight: FontWeight.w600, letterSpacing: -1.2)),
          const SizedBox(height: 10),
          Text(
            'JUST SAY IT.',
            style: WaziText.inter(size: 15, color: WaziColors.teal, letterSpacing: 2.4),
          ),
        ],
    );
  }
}
