import 'dart:async';

import 'package:flutter/material.dart';

/// Expanding, fading ring — Flutter equivalent of the design's wz-ripple /
/// wz-slow CSS keyframes (scale 1 -> maxScale, opacity startOpacity -> 0,
/// looping). Stack several with staggered `delay`s for the "sonar" effect
/// used on the listening mic, splash logo, voiceprint enroll button, and
/// success checkmark.
class PulseRing extends StatefulWidget {
  const PulseRing({
    super.key,
    required this.color,
    required this.size,
    this.duration = const Duration(milliseconds: 2100),
    this.delay = Duration.zero,
    this.maxScale = 2.5,
    this.startOpacity = 0.55,
    this.strokeWidth = 1.5,
  });

  final Color color;
  final double size;
  final Duration duration;
  final Duration delay;
  final double maxScale;
  final double startOpacity;
  final double strokeWidth;

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    // A plain Timer (not Future.delayed) so it can actually be cancelled in
    // dispose() if this ring is removed before its staggered start fires —
    // Future.delayed has no cancel handle, so it would otherwise fire (or
    // at least stay registered) after disposal.
    _startTimer = Timer(widget.delay, () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final scale = 1 + (widget.maxScale - 1) * t;
          final opacity = (widget.startOpacity * (1 - t)).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.color, width: widget.strokeWidth),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
