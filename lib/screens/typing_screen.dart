import 'package:flutter/material.dart';

import '../api/accounts_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chat_bubble.dart';

class TypingScreen extends StatelessWidget {
  const TypingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _ChatTab(appState: appState),
          ),
          _DraftInput(appState: appState),
          WaziBottomNav(appState: appState),
        ],
      ),
    );
  }
}



class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Text('Type to Wazi', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
        const SizedBox(height: 12),
        if (appState.turns.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WaziColors.textAt(.14), style: BorderStyle.solid),
            ),
            child: Text(
              'Same assistant, no talking. Try "send 15k to Amara" or "what did I spend on transport?"',
              style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5)),
            ),
          )
        else
          ...appState.turns.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChatBubble(turn: t, showSpeaking: false),
              )),
      ],
    );
  }
}

class _DraftInput extends StatefulWidget {
  const _DraftInput({required this.appState});

  final AppState appState;

  @override
  State<_DraftInput> createState() => _DraftInputState();
}

class _DraftInputState extends State<_DraftInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.appState.draft);
  }

  @override
  void didUpdateWidget(covariant _DraftInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only resync from state when it diverges from what the field already
    // shows (e.g. cleared to '' after sendDraft) — never on every keystroke,
    // which would fight the user's cursor position.
    if (widget.appState.draft != _controller.text && widget.appState.draft.isEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: WaziColors.card,
          border: Border.all(color: WaziColors.textAt(.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.appState.setDraft,
                onSubmitted: (_) => widget.appState.sendDraft(),
                style: WaziText.inter(size: 14.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a request',
                  hintStyle: WaziText.inter(size: 14.5, color: WaziColors.textAt(.4)),
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.appState.sendDraft,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.gold),
                child: const Icon(Icons.arrow_upward_rounded, size: 18, color: WaziColors.bg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
