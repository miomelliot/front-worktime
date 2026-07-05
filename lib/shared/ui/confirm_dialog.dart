import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: Text(title),
      description: Text(message),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ShadButton.outline(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Cancel')),
          const SizedBox(width: 8),
          ShadButton.destructive(
              onPressed: onConfirm, child: const Text('Confirm')),
        ],
      ),
    );
  }
}
