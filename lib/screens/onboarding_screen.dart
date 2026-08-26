import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pulse_ring.dart';

const _copy = [
  [
    "Talk, don't tap",
    'Say what you want done. Transfers, airtime, bills — Wazi hears it and reads it back before anything moves.',
  ],
  [
    'See where it went',
    'A running picture of your spending, with one honest tip a month instead of a wall of charts.',
  ],
  [
    'Scan and pay',
    'Point at any merchant code. Say "scan this" and the camera is already open.',
  ],
];

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final onb = appState.onb;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => appState.go(AppScreen.welcome),
              child: Text('Skip', style: WaziText.inter(size: 13, color: WaziColors.textAt(.5))),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 210, child: Center(child: _Illustration(step: onb))),
                  const SizedBox(height: 44),
                  Text(
                    _copy[onb][0],
                    style: WaziText.grotesk(size: 34, weight: FontWeight.w600, letterSpacing: -0.85, height: 1.1),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      _copy[onb][1],
                      style: WaziText.inter(size: 16, color: WaziColors.textAt(.62)),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(3, (i) {
                    final active = i == onb;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 7),
                      width: active ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: active ? WaziColors.gold : WaziColors.textAt(.2),
                      ),
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: appState.onbNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WaziColors.gold,
                    foregroundColor: WaziColors.bg,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(
                    onb == 2 ? 'Get started' : 'Next',
                    style: WaziText.grotesk(size: 15, weight: FontWeight.w600, color: WaziColors.bg),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PulseRing(color: WaziColors.tealAt(.55), size: 80, duration: const Duration(milliseconds: 3000), maxScale: 1.9, startOpacity: .35, strokeWidth: 1),
              PulseRing(color: WaziColors.tealAt(.35), size: 80, duration: const Duration(milliseconds: 3000), delay: const Duration(milliseconds: 1000), maxScale: 1.9, startOpacity: .35, strokeWidth: 1),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.teal),
                alignment: Alignment.center,
                child: Container(width: 14, height: 26, decoration: BoxDecoration(color: WaziColors.bg, borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
        );
      case 1:
        final heights = [46.0, 88.0, 132.0, 70.0, 104.0];
        final opacities = [.3, .55, 1.0, .45, .7];
        return SizedBox(
          height: 150,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (i) {
              return Container(
                width: 20,
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 4.5),
                color: WaziColors.goldAt(opacities[i]),
              );
            }),
          ),
        );
      default:
        return const _ScanFrame();
    }
  }
}

class _ScanFrame extends StatefulWidget {
  const _ScanFrame();

  @override
  State<_ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<_ScanFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const inset = 38.0;
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        children: [
          Container(decoration: BoxDecoration(border: Border.all(color: WaziColors.textAt(.12)))),
          const Positioned(top: 0, left: 0, child: _Corner(top: true, left: true)),
          const Positioned(top: 0, right: 0, child: _Corner(top: true, left: false)),
          const Positioned(bottom: 0, left: 0, child: _Corner(top: false, left: true)),
          const Positioned(bottom: 0, right: 0, child: _Corner(top: false, left: false)),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                top: _controller.value * inset,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, WaziColors.gold, Colors.transparent]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: WaziColors.teal, width: 2);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        border: Border(
          top: top ? side : BorderSide.none,
          bottom: !top ? side : BorderSide.none,
          left: left ? side : BorderSide.none,
          right: !left ? side : BorderSide.none,
        ),
      ),
    );
  }
}
