import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_empty_view.dart';
import 'app_error_view.dart';
import 'app_loading_view.dart';

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingMessage,
    this.empty,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => AppLoadingView(message: loadingMessage),
      error: (error, _) => AppErrorView(error: error, onRetry: onRetry),
      data: (result) {
        if (isEmpty?.call(result) ?? false) {
          return empty ?? const AppEmptyView();
        }
        return data(result);
      },
    );
  }
}
