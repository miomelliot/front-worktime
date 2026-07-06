import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../team/application/team_controller.dart';
import '../../team/domain/employee_status.dart';
import '../application/today_controller.dart';
import '../data/today_repository.dart';
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
                const SizedBox(height: AppSpacing.xl),
                _HeroTimerCard(
                  session: session,
                  expected: expected,
                  onStart: controller.start,
                  onPause: controller.pause,
                  onResume: controller.resume,
                  onStop: controller.stop,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatsRow(wide: wide),
                const SizedBox(height: AppSpacing.xl),
                _MiddleGrid(wide: wide, session: session),
                const SizedBox(height: AppSpacing.xl),
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
    final colors = ShadTheme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_dayPartGreeting()}, $name',
          style: TextStyle(
            fontSize: 24,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          date,
          style: TextStyle(fontSize: 14, color: colors.mutedForeground),
        ),
      ],
    );
  }
}

/// The card the whole page revolves around: current status, the running
/// clock against today's target, and the start/pause/stop controls.
class _HeroTimerCard extends StatelessWidget {
  const _HeroTimerCard({
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
    final colors = ShadTheme.of(context).colorScheme;
    final progress = expected.inMinutes == 0
        ? 0.0
        : (session.elapsed.inMinutes / expected.inMinutes).clamp(0.0, 1.0);
    final remaining = expected - session.elapsed;
    final accent = statusAccent(session.status);
    final percent = (progress * 100).round();
    final caption = remaining.inMinutes > 0
        ? '$percent% от дневной нормы · осталось ${_formatShort(remaining)}'
        : '$percent% от дневной нормы · норма выполнена';

    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Сегодня',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.mutedForeground,
                ),
              ),
              const Spacer(),
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
                style: TextStyle(
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: colors.foreground,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ ${_formatShort(expected)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: colors.muted,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(color: accent),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            caption,
            style: TextStyle(fontSize: 13, color: colors.mutedForeground),
          ),
          const SizedBox(height: AppSpacing.xl),
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
      height: 40,
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

/// Three at-a-glance numbers below the hero card. Every tile shares one
/// structure (icon chip, label, value) so they always line up without
/// needing height hacks.
class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(todayStatsProvider);
    return stats.when(
      loading: () => _StatsRowSkeleton(wide: wide),
      error: (error, stackTrace) => _StatsRowSkeleton(wide: wide),
      data: (stats) => _StatsRowData(wide: wide, stats: stats),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final tiles = const [
      StatTile(
        icon: LucideIcons.rotateCcw,
        accent: AppColors.brand,
        title: 'За неделю',
        value: '—',
        suffix: '',
      ),
      StatTile(
        icon: LucideIcons.calendarCheck,
        accent: AppColors.statusWorkingText,
        title: 'Рабочих дней',
        value: '—',
        suffix: '',
      ),
      StatTile(
        icon: LucideIcons.shieldCheck,
        accent: AppColors.muted,
        title: 'Мои нарушения',
        value: '—',
        suffix: '',
      ),
    ];
    return _StatsRowLayout(wide: wide, tiles: tiles);
  }
}

class _StatsRowData extends StatelessWidget {
  const _StatsRowData({required this.wide, required this.stats});

  final bool wide;
  final TodayStats stats;

  @override
  Widget build(BuildContext context) {
    final violationsCount = stats.openViolations;
    final tiles = [
      StatTile(
        icon: LucideIcons.rotateCcw,
        accent: AppColors.brand,
        title: 'За неделю',
        value: _formatShort(Duration(seconds: stats.weeklyWorkedSeconds)),
        suffix: 'из ${_formatShort(Duration(seconds: stats.weeklyExpectedSeconds))}',
      ),
      StatTile(
        icon: LucideIcons.calendarCheck,
        accent: AppColors.statusWorkingText,
        title: 'Рабочих дней',
        value: '${stats.workDaysThisMonth}',
        suffix: 'в этом месяце',
      ),
      StatTile(
        icon: violationsCount == 0
            ? LucideIcons.shieldCheck
            : LucideIcons.triangleAlert,
        accent:
            violationsCount == 0 ? AppColors.statusWorkingText : AppColors.rose,
        title: 'Мои нарушения',
        value: '$violationsCount',
        suffix: violationsCount == 0 ? 'нет открытых' : 'открыто',
      ),
    ];
    return _StatsRowLayout(wide: wide, tiles: tiles);
  }
}

class _StatsRowLayout extends StatelessWidget {
  const _StatsRowLayout({required this.wide, required this.tiles});

  final bool wide;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            tiles[i],
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.lg),
          Expanded(child: tiles[i]),
        ],
      ],
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
          const SizedBox(height: AppSpacing.xl),
          schedule,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: events),
        const SizedBox(width: AppSpacing.xl),
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
    return DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SectionHeader(
            icon: LucideIcons.activity,
            title: 'События дня',
            trailing: visibleEvents.isEmpty
                ? null
                : const Text(
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
    final colors = ShadTheme.of(context).colorScheme;
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
          ),
          Text(
            _formatTime(event.time),
            style: TextStyle(fontSize: 14, color: colors.mutedForeground),
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
    return DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const SectionHeader(
            icon: LucideIcons.calendarClock,
            title: 'Мой график сегодня',
          ),
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
                  isLast: true,
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
  const _ScheduleRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: colors.mutedForeground),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends ConsumerWidget {
  const _DepartmentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamControllerProvider);
    final colleagues = team.value?.employees.take(2).toList() ?? const [];
    return DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const SectionHeader(icon: LucideIcons.users, title: 'Коллеги отдела'),
          if (colleagues.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: EmptyState(
                title: 'Коллеги недоступны',
                message: 'Директория команды видна руководителям и '
                    'администраторам.',
              ),
            )
          else
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
    final colors = ShadTheme.of(context).colorScheme;
    final name = employee.user.name;
    final caption = _departmentCaption(employee.user);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          _Avatar(name: employee.user.name),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _ColleagueIdentity(name: name, caption: caption)),
          const SizedBox(width: AppSpacing.md),
          StatusBadge(status: employee.status),
        ],
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
    final colors = ShadTheme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: colors.mutedForeground),
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
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: AppColors.brand,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
  final clamped = duration.isNegative ? Duration.zero : duration;
  final hours = clamped.inHours;
  final minutes = clamped.inMinutes.remainder(60);
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
    'start' => (AppColors.statusWorkingText, LucideIcons.logIn),
    'pause' => (AppColors.statusPausedText, LucideIcons.coffee),
    'resume' => (AppColors.brand, LucideIcons.rotateCw),
    'stop' => (AppColors.statusStoppedText, LucideIcons.logOut),
    _ => (AppColors.muted, LucideIcons.circle),
  };
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return parts.first.characters.take(2).toString();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

String _departmentCaption(AppUser user) {
  final department = user.department ?? 'Без отдела';
  if (user.title?.isNotEmpty ?? false) return '$department · ${user.title}';
  return department;
}
