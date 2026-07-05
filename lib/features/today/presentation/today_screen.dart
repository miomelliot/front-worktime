import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/mock/mock_users.dart';
import '../../../shared/mock/mock_workday.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../team/domain/employee_status.dart';
import '../application/today_controller.dart';
import '../domain/time_event.dart';
import '../domain/work_session.dart';
import '../domain/work_status.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayControllerProvider);
    final user = ref.watch(authControllerProvider);
    return today.when(
      loading: () => const LoadingState(label: 'Загружаем день'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (session) {
        final controller = ref.read(todayControllerProvider.notifier);
        final expected = Duration(
          minutes: (session.plan.expectedHours * 60).round(),
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingHeader(
                  name: _firstName(user?.name ?? 'Мария'),
                  date: _formatRussianDate(DateTime.now()),
                ),
                const SizedBox(height: AppSpacing.lg),
                _TopDashboardGrid(
                  wide: wide,
                  session: session,
                  expected: expected,
                  onStart: controller.start,
                  onPause: controller.pause,
                  onResume: controller.resume,
                  onStop: controller.stop,
                ),
                const SizedBox(height: AppSpacing.lg),
                _MiddleGrid(
                  wide: wide,
                  session: session,
                ),
                const SizedBox(height: AppSpacing.lg),
                const _DepartmentCard(),
              ],
            );
          },
        );
      },
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name, required this.date});

  final String name;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_dayPartGreeting()}, $name',
          style: const TextStyle(
            fontSize: 22,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          date,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _TopDashboardGrid extends StatelessWidget {
  const _TopDashboardGrid({
    required this.wide,
    required this.session,
    required this.expected,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final bool wide;
  final WorkSession session;
  final Duration expected;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final todayCard = _TodayTimerCard(
      session: session,
      expected: expected,
      onStart: onStart,
      onPause: onPause,
      onResume: onResume,
      onStop: onStop,
    );
    // Spacer-based bottom alignment needs a bounded height, which only the
    // wide layout provides (via IntrinsicHeight). The narrow layout stacks
    // cards inside an unbounded-height scroll view, so it falls back to a
    // fixed gap instead.
    final weekCard = _MetricPanel(
      icon: LucideIcons.rotateCcw,
      iconColor: const Color(0xff1f7cae),
      title: 'За неделю',
      value: '36 ч 08 мин',
      suffix: 'из 40 ч',
      alignValueBottom: wide,
    );
    final daysCard = _MetricPanel(
      icon: LucideIcons.calendarCheck,
      iconColor: AppColors.statusWorkingText,
      title: 'Рабочих дней',
      value: '18',
      suffix: 'в этом месяце',
      alignValueBottom: wide,
    );
    const violationsCard = _MetricPanel(
      icon: LucideIcons.circle,
      iconColor: AppColors.statusPausedText,
      title: 'Мои нарушения',
      value: '0',
      suffix: 'открыто',
      compact: true,
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          todayCard,
          const SizedBox(height: AppSpacing.lg),
          weekCard,
          const SizedBox(height: AppSpacing.lg),
          daysCard,
          const SizedBox(height: AppSpacing.lg),
          violationsCard,
        ],
      );
    }

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 6, child: todayCard),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 4, child: weekCard),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 4, child: daysCard),
              const SizedBox(width: AppSpacing.lg),
              const Expanded(flex: 4, child: violationsCard),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayTimerCard extends StatelessWidget {
  const _TodayTimerCard({
    required this.session,
    required this.expected,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final WorkSession session;
  final Duration expected;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final progress = expected.inMinutes == 0
        ? 0.0
        : (session.elapsed.inMinutes / expected.inMinutes).clamp(0.0, 1.0);
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Сегодня',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              StatusBadge(status: session.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.sm,
            children: [
              Text(
                _formatClock(session.elapsed),
                style: const TextStyle(
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff020617),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${_formatShort(expected)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffa3aab6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              height: 8,
              color: const Color(0xffedf1f4),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(color: AppColors.statusWorkingText),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _TimerActions(
            status: session.status,
            onStart: onStart,
            onPause: onPause,
            onResume: onResume,
            onStop: onStop,
          ),
        ],
      ),
    );
  }
}

class _TimerActions extends StatelessWidget {
  const _TimerActions({
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final WorkStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final primary = switch (status) {
      WorkStatus.notStarted || WorkStatus.shortened => (
          'Начать день',
          LucideIcons.play,
          onStart,
        ),
      WorkStatus.working => (
          'Пауза',
          LucideIcons.pause,
          onPause,
        ),
      WorkStatus.paused => (
          'Продолжить',
          LucideIcons.play,
          onResume,
        ),
      _ => (
          'Недоступно',
          LucideIcons.lock,
          () {},
        ),
    };
    final canStop = status == WorkStatus.working || status == WorkStatus.paused;
    return Row(
      children: [
        Expanded(
          child: _OutlineActionButton(
            label: primary.$1,
            icon: primary.$2,
            enabled: primary.$1 != 'Недоступно',
            onPressed: primary.$3,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _OutlineActionButton(
            label: 'Завершить день',
            icon: LucideIcons.square,
            enabled: canStop,
            onPressed: onStop,
            destructive: true,
          ),
        ),
      ],
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: destructive
          ? ShadButton.destructive(
              enabled: enabled,
              onPressed: onPressed,
              expands: true,
              child: content,
            )
          : ShadButton(
              enabled: enabled,
              onPressed: onPressed,
              expands: true,
              child: content,
            ),
    );
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.suffix,
    this.compact = false,
    this.alignValueBottom = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String suffix;
  final bool compact;
  final bool alignValueBottom;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      minHeight: compact ? 142 : 164,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          if (alignValueBottom) const Spacer() else const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.xs,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff020617),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xff9aa3af)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiddleGrid extends StatelessWidget {
  const _MiddleGrid({required this.wide, required this.session});

  final bool wide;
  final WorkSession session;

  @override
  Widget build(BuildContext context) {
    final events = _TimelinePanel(events: session.events);
    final schedule = _SchedulePanel(session: session);
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          events,
          const SizedBox(height: AppSpacing.lg),
          schedule,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: events),
        const SizedBox(width: AppSpacing.lg),
        Expanded(flex: 5, child: schedule),
      ],
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.events});

  final List<TimeEvent> events;

  @override
  Widget build(BuildContext context) {
    final visibleEvents = events.reversed.take(3).toList();
    return _DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _CardHeader(
            title: 'События дня',
            trailing: Text(
              'Все →',
              style: TextStyle(
                color: AppColors.brand,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (visibleEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: EmptyState(
                title: 'Событий пока нет',
                message: 'Начните рабочий день, чтобы увидеть историю.',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  for (final event in visibleEvents) _EventRow(event: event),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final TimeEvent event;

  @override
  Widget build(BuildContext context) {
    final tone = _eventTone(event.action);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: tone.$1, shape: BoxShape.circle),
            child: Icon(tone.$2, size: 15, color: const Color(0xffffffff)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _eventTitle(event),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            _formatTime(event.time),
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SchedulePanel extends StatelessWidget {
  const _SchedulePanel({required this.session});

  final WorkSession session;

  @override
  Widget build(BuildContext context) {
    final plan = session.plan;
    final days = plan.isShortened ? '5/2, сокращенный' : '5/2';
    return _DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _CardHeader(title: 'Мой график сегодня'),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _ScheduleRow(
                  label: 'График',
                  value: '$days, ${plan.plannedStart}-${plan.plannedEnd}',
                ),
                _ScheduleRow(
                    label: 'Плановое начало', value: plan.plannedStart),
                _ScheduleRow(label: 'Плановый конец', value: plan.plannedEnd),
                _ScheduleRow(
                  label: 'Обеденный перерыв',
                  value: '${plan.breakMinutes} мин',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff020617),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard();

  @override
  Widget build(BuildContext context) {
    final colleagues = mockEmployeeStatuses.take(2).toList();
    return _DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _CardHeader(title: 'Коллеги отдела'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                for (final colleague in colleagues)
                  _ColleagueRow(employee: colleague),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColleagueRow extends StatelessWidget {
  const _ColleagueRow({required this.employee});

  final EmployeeStatus employee;

  @override
  Widget build(BuildContext context) {
    final name = employee.user.name;
    final caption = _departmentCaption(employee.user);
    final worked =
        '${employee.actualHours.toStringAsFixed(0)} ч ${((employee.actualHours % 1) * 60).round()} мин';
    final planned = 'из ${employee.plannedHours.toStringAsFixed(0)} ч';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffeef0f2))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final identity = _ColleagueIdentity(name: name, caption: caption);
          final time = _ColleagueTime(worked: worked, planned: planned);

          if (narrow) {
            return Column(
              children: [
                Row(
                  children: [
                    _Avatar(name: employee.user.name),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: identity),
                    const SizedBox(width: AppSpacing.md),
                    StatusBadge(status: employee.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(child: time),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              _Avatar(name: employee.user.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: identity),
              const SizedBox(width: AppSpacing.md),
              time,
              const SizedBox(width: AppSpacing.md),
              StatusBadge(status: employee.status),
            ],
          );
        },
      ),
    );
  }
}

class _ColleagueIdentity extends StatelessWidget {
  const _ColleagueIdentity({required this.name, required this.caption});

  final String name;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Color(0xffa0a7b1)),
        ),
      ],
    );
  }
}

class _ColleagueTime extends StatelessWidget {
  const _ColleagueTime({required this.worked, required this.planned});

  final String worked;
  final String planned;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          worked,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff020617),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          planned,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 12, color: Color(0xffa0a7b1)),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xffeaf2f8),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Color(0xff1f7cae),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffeef0f2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff020617),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.minHeight,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: ShadCard(
        radius: AppRadius.card,
        padding: padding,
        child: child,
      ),
    );
  }
}

String _dayPartGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 6) return 'Доброй ночи';
  if (hour < 12) return 'Доброе утро';
  if (hour < 18) return 'Добрый день';
  if (hour < 23) return 'Добрый вечер';
  return 'Доброй ночи';
}

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Мария';
  return trimmed.split(RegExp(r'\s+')).first;
}

String _formatRussianDate(DateTime date) {
  const weekdays = [
    'понедельник',
    'вторник',
    'среда',
    'четверг',
    'пятница',
    'суббота',
    'воскресенье',
  ];
  const months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatClock(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String _formatShort(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '$minutes мин';
  if (minutes == 0) return '$hours ч 00 мин';
  return '$hours ч $minutes мин';
}

String _formatTime(DateTime time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _eventTitle(TimeEvent event) {
  return switch (event.action) {
    'start' => 'Рабочий день начат',
    'pause' => 'Пауза',
    'resume' => 'Работа продолжена',
    'stop' => 'Рабочий день завершен',
    _ => event.note,
  };
}

(Color, IconData) _eventTone(String action) {
  return switch (action) {
    'start' => (AppColors.statusWorkingText, LucideIcons.play),
    'pause' => (AppColors.statusPausedText, LucideIcons.pause),
    'resume' => (const Color(0xff2f87b8), LucideIcons.play),
    'stop' => (AppColors.statusStoppedText, LucideIcons.square),
    _ => (AppColors.textMuted, LucideIcons.circle),
  };
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return parts.first.characters.take(2).toString();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

String _departmentCaption(AppUser user) {
  final managers = mockUsers.where((u) => u.id == user.managerId);
  final managerName = managers.isEmpty ? '—' : managers.first.name;
  return '${user.department} · рук.: $managerName';
}
