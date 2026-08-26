import 'package:flutter/material.dart';

import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// User bubbles are right-aligned, plain. AI bubbles are left-aligned, teal
/// gradient, and grow an animated three-bar "speaking" indicator when
/// `turn.speaking` is true and this is the latest turn.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.turn, required this.showSpeaking});

  final ChatTurn turn;
  final bool showSpeaking;

  @override
  Widget build(BuildContext context) {
    final isUser = turn.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: isUser ? 255 : 265),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isUser ? WaziColors.textAt(.09) : null,
          gradient: isUser
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [WaziColors.tealAt(.16), WaziColors.tealAt(.05)],
                ),
          border: Border.all(color: isUser ? WaziColors.textAt(.08) : WaziColors.tealAt(.28)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Text(turn.text, style: WaziText.inter(size: 14.5, height: 1.45))),
            if (!isUser && turn.speaking && showSpeaking) const Padding(
              padding: EdgeInsets.only(left: 8),
              child: _SpeakingBars(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeakingBars extends StatefulWidget {
  const _SpeakingBars();

  @override
  State<_SpeakingBars> createState() => _SpeakingBarsState();
}

class _SpeakingBarsState extends State<_SpeakingBars> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scaleFor(double phaseOffset) {
    final t = (_controller.value + phaseOffset) % 1.0;
    // matches wz-bar: scaleY .3 at 0%/100%, 1 at 50% (a triangle wave)
    return t < 0.5 ? 0.3 + 1.4 * t : 0.3 + 1.4 * (1 - t);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [0.0, 0.2, 0.4].map((phase) {
              return Container(
                width: 2,
                height: 12,
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: WaziColors.teal,
                  borderRadius: BorderRadius.circular(1),
                ),
                transform: Matrix4.diagonal3Values(1.0, _scaleFor(phase), 1.0),
                transformAlignment: Alignment.bottomCenter,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
