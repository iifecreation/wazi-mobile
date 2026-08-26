import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WaziColors.scanBg,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => widget.appState.go(AppScreen.home),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: WaziColors.bg.withValues(alpha: .7),
                        border: Border.all(color: WaziColors.textAt(.14)),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                  Text('SCAN TO PAY', style: WaziText.grotesk(size: 13, weight: FontWeight.w500, color: WaziColors.textAt(.7), letterSpacing: 1.4)),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: SizedBox(
                  width: 246,
                  height: 246,
                  child: Stack(
                    children: [
                      Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: WaziColors.textAt(.03))),
                      _corner(top: true, left: true),
                      _corner(top: true, left: false),
                      _corner(top: false, left: true),
                      _corner(top: false, left: false),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Positioned(
                            left: 15,
                            right: 15,
                            top: 15 + _controller.value * 216,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.transparent, WaziColors.teal, Colors.transparent]),
                                boxShadow: [BoxShadow(color: WaziColors.tealAt(.7), blurRadius: 18)],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: Text(
                'Point at any Wazi or NIBSS code',
                textAlign: TextAlign.center,
                style: WaziText.inter(size: 14, color: WaziColors.textAt(.65)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: AnimatedBuilder(
                animation: widget.appState,
                builder: (context, _) {
                  return Column(
                    children: [
                      if (widget.appState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(widget.appState.error!, style: WaziText.inter(size: 12.5, color: WaziColors.gold)),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: widget.appState.busy ? null : widget.appState.scanFound,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WaziColors.gold,
                              foregroundColor: WaziColors.bg,
                              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                            child: widget.appState.busy
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                                : Text('Simulate code found', style: WaziText.grotesk(size: 14.5, weight: FontWeight.w600, color: WaziColors.bg)),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: widget.appState.onMic,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: WaziColors.tealAt(.5))),
                              child: const Icon(Icons.mic_rounded, size: 18, color: WaziColors.teal),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _corner({required bool top, required bool left}) {
    final side = const BorderSide(color: WaziColors.teal, width: 3);
    return Positioned(
      top: top ? 0 : null,
      bottom: !top ? 0 : null,
      left: left ? 0 : null,
      right: !left ? 0 : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: !top ? side : BorderSide.none,
            left: left ? side : BorderSide.none,
            right: !left ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
