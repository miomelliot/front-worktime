import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      backgroundColor: const Color(0xfffff1f2),
      child: Text(message, style: const TextStyle(color: Color(0xffbe123c))),
    );
  }
}
