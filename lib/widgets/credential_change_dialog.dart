import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

Future<String?> _promptValue(
  BuildContext context, {
  required String title,
  required String hint,
  required bool obscure,
  required TextInputType keyboardType,
  int? maxLength,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: WaziColors.card,
      title: Text(title, style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
      content: TextField(
        controller: controller,
        autofocus: true,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: WaziText.inter(size: 16, color: Colors.white),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white38), counterText: ''),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Continue')),
      ],
    ),
  );
}

/// Shared "current value -> new value" flow behind every "Change
/// Password"/"Change Payment PIN" tile in the settings screens — same real
/// action voice's "change my password"/"change my pin" drives (see
/// app/dialogue/manager.py's multi-turn credential-change flow), just
/// typed here instead of spoken either way (neither value ever leaves this
/// dialog as a live transcript).
Future<void> showChangeCredentialDialog(
  BuildContext context, {
  required String title,
  required String oldHint,
  required String newHint,
  required bool isPin,
  required Future<void> Function(String oldValue, String newValue) onSubmit,
}) async {
  final oldValue = await _promptValue(
    context,
    title: 'Current $title',
    hint: oldHint,
    obscure: !isPin,
    keyboardType: isPin ? TextInputType.number : TextInputType.visiblePassword,
    maxLength: isPin ? 4 : null,
  );
  if (oldValue == null || oldValue.isEmpty || !context.mounted) return;

  final newValue = await _promptValue(
    context,
    title: 'New $title',
    hint: newHint,
    obscure: !isPin,
    keyboardType: isPin ? TextInputType.number : TextInputType.visiblePassword,
    maxLength: isPin ? 4 : null,
  );
  if (newValue == null || newValue.isEmpty || !context.mounted) return;

  try {
    await onSubmit(oldValue, newValue);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title changed.')));
  } on ApiException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
  }
}
