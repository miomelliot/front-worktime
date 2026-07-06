import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/today/domain/work_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'status_badge.dart';

class TimerCard extends StatelessWidget {
  const TimerCard({
    super.key,
    required this.status,
    required this.elapsed,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final WorkStatus status;
  final Duration elapsed;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final primary = _primaryAction(status);
    final secondary = _secondaryActions(status);
    return ShadCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Текущий рабочий день',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Рабочее пространство сотрудника',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _format(elapsed),
            style: const TextStyle(
              fontSize: 56,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Учтено сегодня',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _statusHint(status),
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ShadButton(
                enabled: primary.enabled,
                onPressed: primary.callback(
                  onStart: onStart,
                  onPause: onPause,
                  onResume: onResume,
                  onStop: onStop,
                ),
                child: _ButtonLabel(icon: primary.icon, label: primary.label),
              ),
              for (final action in secondary)
                action.destructive
                    ? ShadButton.destructive(
                        enabled: action.enabled,
                        onPressed: action.callback(
                          onStart: onStart,
                          onPause: onPause,
                          onResume: onResume,
                          onStop: onStop,
                        ),
                        child: _ButtonLabel(
                            icon: action.icon, label: action.label),
                      )
                    : ShadButton.outline(
                        enabled: action.enabled,
                        onPressed: action.callback(
                          onStart: onStart,
                          onPause: onPause,
                          onResume: onResume,
                          onStop: onStop,
                        ),
                        child: _ButtonLabel(
                            icon: action.icon, label: action.label),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}

class _TimerAction {
  const _TimerAction({
    required this.label,
    required this.icon,
    required this.type,
    this.enabled = true,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final _TimerActionType type;
  final bool enabled;
  final bool destructive;

  VoidCallback callback({
    required VoidCallback onStart,
    required VoidCallback onPause,
    required VoidCallback onResume,
    required VoidCallback onStop,
  }) {
    return switch (type) {
      _TimerActionType.start => onStart,
      _TimerActionType.pause => onPause,
      _TimerActionType.resume => onResume,
      _TimerActionType.stop => onStop,
      _TimerActionType.none => () {},
    };
  }
}

enum _TimerActionType { start, pause, resume, stop, none }

_TimerAction _primaryAction(WorkStatus status) {
  return switch (status) {
    WorkStatus.notStarted => const _TimerAction(
        label: 'Начать работу',
        icon: LucideIcons.play,
        type: _TimerActionType.start,
      ),
    WorkStatus.working => const _TimerAction(
        label: 'Взять паузу',
        icon: LucideIcons.pause,
        type: _TimerActionType.pause,
      ),
    WorkStatus.paused => const _TimerAction(
        label: 'Продолжить',
        icon: LucideIcons.play,
        type: _TimerActionType.resume,
      ),
    WorkStatus.stopped => const _TimerAction(
        label: 'День завершен',
        icon: LucideIcons.check,
        type: _TimerActionType.none,
        enabled: false,
      ),
    WorkStatus.incomplete => const _TimerAction(
        label: 'Смена не завершена',
        icon: LucideIcons.triangleAlert,
        type: _TimerActionType.none,
        enabled: false,
      ),
    WorkStatus.dayOff || WorkStatus.holiday => const _TimerAction(
        label: 'Работа не запланирована',
        icon: LucideIcons.calendarOff,
        type: _TimerActionType.none,
        enabled: false,
      ),
    WorkStatus.shortened => const _TimerAction(
        label: 'Начать короткий день',
        icon: LucideIcons.play,
        type: _TimerActionType.start,
      ),
    WorkStatus.vacationDisplayOnly ||
    WorkStatus.sickDisplayOnly =>
      const _TimerAction(
        label: 'Недоступно',
        icon: LucideIcons.lock,
        type: _TimerActionType.none,
        enabled: false,
      ),
  };
}

List<_TimerAction> _secondaryActions(WorkStatus status) {
  return switch (status) {
    WorkStatus.working => const [
        _TimerAction(
          label: 'Завершить',
          icon: LucideIcons.square,
          type: _TimerActionType.stop,
          destructive: true,
        ),
      ],
    WorkStatus.paused => const [
        _TimerAction(
          label: 'Завершить',
          icon: LucideIcons.square,
          type: _TimerActionType.stop,
          destructive: true,
        ),
      ],
    _ => const [],
  };
}

String _statusHint(WorkStatus status) {
  return switch (status) {
    WorkStatus.notStarted =>
      'Смену можно начать, когда вы готовы приступить к работе.',
    WorkStatus.working =>
      'Таймер идет. Можно поставить день на паузу или завершить смену.',
    WorkStatus.paused => 'Рабочее время остановлено до возвращения с перерыва.',
    WorkStatus.stopped => 'Смена закрыта, события дня сохранены в таймлайне.',
    WorkStatus.incomplete =>
      'Смена завершилась без штатной остановки — уточните у сотрудника.',
    WorkStatus.dayOff => 'Сегодня выходной, рабочее время не ожидается.',
    WorkStatus.holiday => 'Сегодня праздничный день, действия отключены.',
    WorkStatus.shortened => 'Сегодня сокращенный рабочий день.',
    WorkStatus.vacationDisplayOnly => 'Сотрудник в отпуске.',
    WorkStatus.sickDisplayOnly => 'Сотрудник на больничном.',
  };
}

String _format(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
