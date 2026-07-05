import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/today/domain/time_event.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'empty_state.dart';

class TimeEventTimeline extends StatelessWidget {
  const TimeEventTimeline({super.key, required this.events});

  final List<TimeEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyState(
          title: 'Событий пока нет',
          message: 'Когда вы начнете рабочий день, события появятся здесь.');
    }
    return ShadCard(
      radius: AppRadius.card,
      title: const Text('События дня'),
      description: const Text('Старт, паузы, возвращения и завершение смены'),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          children: [
            for (final event in events)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(_formatTime(event.time),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: _eventTone(event.action).$1,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _eventTone(event.action).$3,
                        size: 14,
                        color: _eventTone(event.action).$2,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_eventLabel(event.action),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(event.note,
                              style:
                                  const TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _eventLabel(String action) {
  return switch (action) {
    'start' => 'Старт',
    'pause' => 'Пауза',
    'resume' => 'Возврат',
    'stop' => 'Завершение',
    _ => action,
  };
}

(Color, Color, IconData) _eventTone(String action) {
  return switch (action) {
    'start' => (
        AppColors.statusWorkingBg,
        AppColors.statusWorkingText,
        LucideIcons.play
      ),
    'pause' => (
        AppColors.statusPausedBg,
        AppColors.statusPausedText,
        LucideIcons.pause
      ),
    'resume' => (
        AppColors.statusNotStartedBg,
        AppColors.statusNotStartedText,
        LucideIcons.rotateCcw
      ),
    'stop' => (
        AppColors.statusStoppedBg,
        AppColors.statusStoppedText,
        LucideIcons.square
      ),
    _ => (AppColors.surfaceMuted, AppColors.textMuted, LucideIcons.circle),
  };
}
