import 'package:flutter/material.dart';

import '../errors/app_error.dart';
import '../errors/error_mapper.dart';

/// Standard full-area error state with an optional retry action.
///
/// Accepts any [Object]; it is normalized through [ErrorMapper] so callers can
/// pass a raw error/stackTrace (e.g. from an `AsyncValue.error`) directly.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final appError = ErrorMapper.map(error);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconFor(appError.kind),
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              appError.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AppErrorKind kind) {
    switch (kind) {
      case AppErrorKind.network:
        return Icons.wifi_off;
      case AppErrorKind.notFound:
        return Icons.search_off;
      case AppErrorKind.forbidden:
      case AppErrorKind.unauthorized:
        return Icons.lock_outline;
      default:
        return Icons.error_outline;
    }
  }
}
