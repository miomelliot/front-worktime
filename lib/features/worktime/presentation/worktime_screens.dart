import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/date_formats.dart';
import '../../../core/utils/duration_formats.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/worktime_page.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../shared_models/enums.dart';
import '../data/worktime_api.dart';
import '../data/worktime_providers.dart';
import '../domain/worktime_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).userOrNull;
    final dashboard = ref.watch(dashboardProvider);
    return WorktimePage(
      title: 'Рабочий день',
      subtitle: user == null ? null : 'Здравствуйте, ${user.fullName}',
      actions: [
        _RefreshButton(onPressed: () => ref.invalidate(dashboardProvider))
      ],
      child: AsyncValueView(
        value: dashboard,
        onRetry: () => ref.invalidate(dashboardProvider),
        data: (data) => _DashboardContent(data: data),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final session = data.session;
    final today = data.calendar.days.where((day) {
      final now = DateTime.now();
      return day.date.year == now.year &&
          day.date.month == now.month &&
          day.date.day == now.day;
    }).firstOrNull;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 840 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 2.5 : 2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricTile(
                  label: 'Статус сегодня',
                  value: _sessionLabel(session),
                  icon: Icons.work_history_outlined,
                ),
                MetricTile(
                  label: 'Отработано',
                  value: ApiDuration.formatHm(session?.workedSeconds ?? 0),
                  icon: Icons.schedule,
                ),
                MetricTile(
                  label: 'План',
                  value: ApiDuration.formatHm(today?.expectedSeconds ?? 0),
                  icon: Icons.flag_outlined,
                ),
                MetricTile(
                  label: 'Открытые нарушения',
                  value: data.violations.open.toString(),
                  icon: Icons.warning_amber_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        WorktimeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ближайшие дни',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              for (final day in data.calendar.days.take(7))
                _CalendarDayRow(day: day),
            ],
          ),
        ),
      ],
    );
  }
}

class TimeTrackerScreen extends ConsumerStatefulWidget {
  const TimeTrackerScreen({super.key});

  @override
  ConsumerState<TimeTrackerScreen> createState() => _TimeTrackerScreenState();
}

class _TimeTrackerScreenState extends ConsumerState<TimeTrackerScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _action(String action) async {
    final user = ref.read(authControllerProvider).userOrNull;
    if (user == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(worktimeApiProvider).timeAction(
            action: action,
            userId: user.id,
          );
      ref.invalidate(todaySessionProvider);
      ref.invalidate(dashboardProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = ErrorMapper.map(e).message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(todaySessionProvider);
    return WorktimePage(
      title: 'Таймер',
      subtitle: 'Старт, пауза, продолжение и завершение рабочего дня.',
      actions: [
        _RefreshButton(onPressed: () => ref.invalidate(todaySessionProvider)),
      ],
      child: AsyncValueView(
        value: session,
        onRetry: () => ref.invalidate(todaySessionProvider),
        data: (data) => _TimerPanel(
          session: data,
          busy: _busy,
          error: _error,
          onAction: _action,
        ),
      ),
    );
  }
}

class _TimerPanel extends StatelessWidget {
  const _TimerPanel({
    required this.session,
    required this.busy,
    required this.error,
    required this.onAction,
  });

  final WorkSession? session;
  final bool busy;
  final String? error;
  final Future<void> Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    final status = session?.status;
    final worked = session == null
        ? 0
        : status == WorkSessionStatus.working && session!.startedAt != null
            ? DateTime.now().difference(session!.startedAt!).inSeconds -
                session!.pauseSeconds
            : session!.workedSeconds;
    final safeWorked = worked < (session?.workedSeconds ?? 0)
        ? (session?.workedSeconds ?? 0)
        : worked;

    return WorktimeCard(
      child: Column(
        children: [
          Icon(_statusIcon(status), size: 64),
          const SizedBox(height: 16),
          Text(
            ApiDuration.formatHms(safeWorked),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(_sessionLabel(session)),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              if (session == null)
                FilledButton.icon(
                  onPressed: busy ? null : () => onAction('start'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Начать'),
                ),
              if (status == WorkSessionStatus.working) ...[
                FilledButton.tonalIcon(
                  onPressed: busy ? null : () => onAction('pause'),
                  icon: const Icon(Icons.pause),
                  label: const Text('Пауза'),
                ),
                FilledButton.icon(
                  onPressed: busy ? null : () => onAction('stop'),
                  icon: const Icon(Icons.stop),
                  label: const Text('Завершить'),
                ),
              ],
              if (status == WorkSessionStatus.paused) ...[
                FilledButton.icon(
                  onPressed: busy ? null : () => onAction('resume'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Продолжить'),
                ),
                FilledButton.tonalIcon(
                  onPressed: busy ? null : () => onAction('stop'),
                  icon: const Icon(Icons.stop),
                  label: const Text('Завершить'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(myCalendarProvider);
    return WorktimePage(
      title: 'Календарь',
      subtitle: 'Плановые дни, отсутствия и фактически отработанное время.',
      actions: [
        _RefreshButton(onPressed: () => ref.invalidate(myCalendarProvider))
      ],
      child: AsyncValueView(
        value: calendar,
        onRetry: () => ref.invalidate(myCalendarProvider),
        empty: const AppEmptyView(title: 'Нет дней в календаре'),
        isEmpty: (data) => data.days.isEmpty,
        data: (data) => WorktimeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final day in data.days)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CalendarDayRow(day: day),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizationStatusScreen extends ConsumerWidget {
  const OrganizationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(departmentsStateProvider);
    return WorktimePage(
      title: 'Команда',
      subtitle: 'Текущий статус сотрудников и отделов.',
      actions: [
        _RefreshButton(
            onPressed: () => ref.invalidate(departmentsStateProvider)),
      ],
      child: AsyncValueView(
        value: state,
        onRetry: () => ref.invalidate(departmentsStateProvider),
        data: (data) => Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: columns == 4 ? 2.4 : 1.8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    MetricTile(
                        label: 'Работают',
                        value: '${data.working}',
                        icon: Icons.play_circle_outline),
                    MetricTile(
                        label: 'На паузе',
                        value: '${data.paused}',
                        icon: Icons.pause_circle_outline),
                    MetricTile(
                        label: 'Завершили',
                        value: '${data.finished}',
                        icon: Icons.check_circle_outline),
                    MetricTile(
                        label: 'Нарушения',
                        value: '${data.openViolations}',
                        icon: Icons.report_problem_outlined),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            for (final department in data.departments)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WorktimeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(department.departmentName,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        '${department.totalEmployees} сотрудников · ${department.working} работают · ${department.paused} на паузе',
                      ),
                      const Divider(height: 24),
                      for (final employee in department.employees.take(8))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_outline),
                          title: Text(employee.fullName),
                          subtitle: Text(employee.email),
                          trailing: Text(_memberStatus(employee)),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _timezone = TextEditingController();
  final _position = TextEditingController();
  bool _ready = false;
  bool _saving = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _timezone.dispose();
    _position.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final user = await ref.read(worktimeApiProvider).updateMe(
            fullName: _name.text.trim(),
            timezone: _timezone.text.trim(),
            position:
                _position.text.trim().isEmpty ? null : _position.text.trim(),
          );
      ref.read(authControllerProvider.notifier).refresh();
      setState(() => _message = 'Профиль обновлен: ${user.fullName}');
    } on Object catch (e) {
      setState(() => _message = ErrorMapper.map(e).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final data = await _passwordDialog(context);
    if (!mounted || data == null) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref.read(worktimeApiProvider).changePassword(
            currentPassword: data.currentPassword,
            newPassword: data.newPassword,
          );
      setState(() => _message = 'Пароль обновлен');
    } on Object catch (e) {
      setState(() => _message = ErrorMapper.map(e).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).userOrNull;
    if (user != null && !_ready) {
      _ready = true;
      _name.text = user.fullName;
      _timezone.text = user.timezone;
      _position.text = user.position ?? '';
    }

    return WorktimePage(
      title: 'Профиль',
      subtitle: user?.email,
      actions: [
        IconButton(
          tooltip: 'Выйти',
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      child: WorktimeCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Полное имя')),
            const SizedBox(height: 12),
            TextField(
                controller: _position,
                decoration: const InputDecoration(labelText: 'Должность')),
            const SizedBox(height: 12),
            TextField(
                controller: _timezone,
                decoration: const InputDecoration(labelText: 'Часовой пояс')),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (user?.canChangePassword == true)
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _changePassword,
                      icon: const Icon(Icons.password_outlined),
                      label: const Text('Сменить пароль'),
                    ),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Сохранить'),
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

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  Future<void> _assignOrg(
    BuildContext context,
    WidgetRef ref,
    UserProfile user,
  ) async {
    final departments = ref.read(departmentsProvider).valueOrNull ?? const [];
    final users = ref.read(usersProvider).valueOrNull ?? const [];
    final result = await _organizationDialog(
      context,
      departments: departments,
      users: users,
    );
    if (!context.mounted) return;
    if (result == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).assignUserOrganization(
            userId: user.id,
            departmentId: result.departmentId,
            managerId: result.managerId,
          ),
    );
    ref.invalidate(usersProvider);
  }

  Future<void> _deleteUser(
    BuildContext context,
    WidgetRef ref,
    UserProfile user,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Уволить пользователя?',
      message: '${user.fullName} будет переведен в статус fired.',
    );
    if (!context.mounted) return;
    if (!confirmed) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).deleteUser(user.id),
    );
    ref.invalidate(usersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    ref.watch(departmentsProvider);
    return _AdminPage(
      title: 'Пользователи',
      child: AsyncValueView(
        value: users,
        onRetry: () => ref.invalidate(usersProvider),
        isEmpty: (items) => items.isEmpty,
        data: (items) => WorktimeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final user in items)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(user.fullName),
                  subtitle: Text('${user.email} · ${user.status.name}'),
                  trailing: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<RoleCode>(
                        value: user.role,
                        onChanged: (role) async {
                          if (role == null) return;
                          await _runAdminAction(
                            context,
                            () => ref.read(worktimeApiProvider).updateUserRole(
                                  id: user.id,
                                  role: role.name,
                                ),
                          );
                          ref.invalidate(usersProvider);
                        },
                        items: RoleCode.values
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.name),
                                ))
                            .toList(),
                      ),
                      IconButton(
                        tooltip: 'Отдел и менеджер',
                        onPressed: () => _assignOrg(context, ref, user),
                        icon: const Icon(Icons.account_tree_outlined),
                      ),
                      IconButton(
                        tooltip: 'Уволить',
                        onPressed: () => _deleteUser(context, ref, user),
                        icon: const Icon(Icons.person_remove_outlined),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDepartmentsScreen extends ConsumerWidget {
  const AdminDepartmentsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final departments = ref.read(departmentsProvider).valueOrNull ?? const [];
    final data = await _departmentDialog(context, departments: departments);
    if (!context.mounted) return;
    if (data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).createDepartment(
            name: data.name,
            parentId: data.parentId,
          ),
    );
    ref.invalidate(departmentsProvider);
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) async {
    final departments = (ref.read(departmentsProvider).valueOrNull ?? const [])
        .where((item) => item.id != department.id)
        .toList();
    final data = await _departmentDialog(
      context,
      departments: departments,
      initial: department,
    );
    if (!context.mounted) return;
    if (data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).updateDepartment(
            id: department.id,
            name: data.name,
            parentId: data.parentId,
          ),
    );
    ref.invalidate(departmentsProvider);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Удалить отдел?',
      message: department.name,
    );
    if (!context.mounted) return;
    if (!confirmed) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).deleteDepartment(department.id),
    );
    ref.invalidate(departmentsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentsProvider);
    return _AdminPage(
      title: 'Отделы',
      action: FilledButton.icon(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      child: AsyncValueView(
        value: departments,
        onRetry: () => ref.invalidate(departmentsProvider),
        isEmpty: (items) => items.isEmpty,
        data: (items) => WorktimeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final department in items)
                ListTile(
                  leading: const Icon(Icons.apartment_outlined),
                  title: Text(department.name),
                  subtitle: Text(department.parentId == null
                      ? 'Корневой отдел'
                      : 'Родитель: ${department.parentId}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        tooltip: 'Редактировать',
                        onPressed: () => _edit(context, ref, department),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Удалить',
                        onPressed: () => _delete(context, ref, department),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminSchedulesScreen extends ConsumerWidget {
  const AdminSchedulesScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final data = await _scheduleDialog(context);
    if (!context.mounted) return;
    if (data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).createSchedule(data),
    );
    ref.invalidate(schedulesProvider);
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    WorkSchedule schedule,
  ) async {
    final data = await _scheduleDialog(context, initial: schedule);
    if (!context.mounted) return;
    if (data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).updateSchedule(schedule.id, data),
    );
    ref.invalidate(schedulesProvider);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkSchedule schedule,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Удалить график?',
      message: schedule.name,
    );
    if (!context.mounted) return;
    if (!confirmed) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).deleteSchedule(schedule.id),
    );
    ref.invalidate(schedulesProvider);
  }

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref,
    WorkSchedule schedule,
  ) async {
    final users = ref.read(usersProvider).valueOrNull ?? const [];
    final data = await _scheduleAssignmentDialog(
      context,
      users: users,
      schedule: schedule,
    );
    if (!context.mounted || data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).createScheduleAssignment(data),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(schedulesProvider);
    ref.watch(usersProvider);
    return _AdminPage(
      title: 'Графики',
      action: FilledButton.icon(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      child: AsyncValueView(
        value: schedules,
        onRetry: () => ref.invalidate(schedulesProvider),
        isEmpty: (items) => items.isEmpty,
        data: (items) => WorktimeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final schedule in items)
                _ScheduleCard(
                  schedule: schedule,
                  onEdit: () => _edit(context, ref, schedule),
                  onDelete: () => _delete(context, ref, schedule),
                  onAssign: () => _assign(context, ref, schedule),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
    required this.onAssign,
  });

  final WorkSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.event_repeat_outlined),
      title: Text(schedule.name),
      subtitle: Text('${schedule.scheduleType.name} · ${schedule.timezone}'),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
              '${schedule.startGraceSeconds ~/ 60}/${schedule.stopGraceSeconds ~/ 60} мин'),
          IconButton(
            tooltip: 'Назначить',
            onPressed: onAssign,
            icon: const Icon(Icons.person_add_alt_outlined),
          ),
          IconButton(
            tooltip: 'Редактировать',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Удалить',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _ScheduleDaysSection(schedule: schedule),
        ),
      ],
    );
  }
}

class _ScheduleDaysSection extends ConsumerWidget {
  const _ScheduleDaysSection({required this.schedule});

  final WorkSchedule schedule;

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final data = await _scheduleDayDialog(context);
    if (!context.mounted || data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).createScheduleDay(
            scheduleId: schedule.id,
            data: data,
          ),
    );
    ref.invalidate(scheduleDaysProvider(schedule.id));
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    WorkScheduleDay day,
  ) async {
    final data = await _scheduleDayDialog(context, initial: day);
    if (!context.mounted || data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).updateScheduleDay(
            id: day.id,
            data: data,
          ),
    );
    ref.invalidate(scheduleDaysProvider(schedule.id));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkScheduleDay day,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Удалить день графика?',
      message: 'День ${day.weekday}',
    );
    if (!context.mounted || !confirmed) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).deleteScheduleDay(day.id),
    );
    ref.invalidate(scheduleDaysProvider(schedule.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(scheduleDaysProvider(schedule.id));
    return AsyncValueView(
      value: days,
      onRetry: () => ref.invalidate(scheduleDaysProvider(schedule.id)),
      empty: AppEmptyView(
        title: 'Дни графика не настроены',
        action: OutlinedButton.icon(
          onPressed: () => _create(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Добавить день'),
        ),
      ),
      isEmpty: (items) => items.isEmpty,
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Добавить день'),
            ),
          ),
          const SizedBox(height: 8),
          for (final day in items.sortedBy<num>((item) => item.weekday))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(day.isWorking
                  ? Icons.calendar_today_outlined
                  : Icons.weekend_outlined),
              title: Text('День ${day.weekday}'),
              subtitle: Text(day.isWorking
                  ? '${ApiDuration.formatTimeOfDayFromNanos(day.startTime) ?? '--:--'} — ${ApiDuration.formatTimeOfDayFromNanos(day.endTime) ?? '--:--'} · ${ApiDuration.formatHm(day.expectedSeconds)}'
                  : 'Выходной'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    tooltip: 'Редактировать',
                    onPressed: () => _edit(context, ref, day),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Удалить',
                    onPressed: () => _delete(context, ref, day),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AdminAbsencesScreen extends ConsumerStatefulWidget {
  const AdminAbsencesScreen({super.key});

  @override
  ConsumerState<AdminAbsencesScreen> createState() =>
      _AdminAbsencesScreenState();
}

class _AdminAbsencesScreenState extends ConsumerState<AdminAbsencesScreen> {
  DateTime _date = DateTime.now();

  Future<void> _createType() async {
    final data = await _absenceTypeDialog(context);
    if (!mounted || data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).createAbsenceType(data),
    );
    ref.invalidate(absenceTypesProvider);
  }

  Future<void> _editType(AbsenceType type) async {
    final data = await _absenceTypeDialog(context, initial: type);
    if (!mounted || data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).updateAbsenceType(type.id, data),
    );
    ref.invalidate(absenceTypesProvider);
  }

  Future<void> _deleteType(AbsenceType type) async {
    final confirmed = await _confirm(
      context,
      title: 'Удалить тип отсутствия?',
      message: type.name,
    );
    if (!mounted || !confirmed) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).deleteAbsenceType(type.id),
    );
    ref.invalidate(absenceTypesProvider);
  }

  Future<void> _create() async {
    final users = ref.read(usersProvider).valueOrNull ?? const [];
    final types = ref.read(absenceTypesProvider).valueOrNull ?? const [];
    final data = await _absenceDialog(context, users: users, types: types);
    if (!mounted) return;
    if (data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).createAbsence(data),
    );
    ref.invalidate(absencesByDateProvider(_date));
  }

  Future<void> _cancel(Absence absence) async {
    final reason = await _textDialog(
      context,
      title: 'Отменить отсутствие',
      label: 'Причина',
      actionLabel: 'Отменить',
      requiredValue: false,
    );
    if (!mounted) return;
    if (reason == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).cancelAbsence(
            absence.id,
            reason: reason,
          ),
    );
    ref.invalidate(absencesByDateProvider(_date));
  }

  Future<void> _delete(Absence absence) async {
    final confirmed = await _confirm(
      context,
      title: 'Удалить отсутствие?',
      message: absence.reason ?? absence.id,
    );
    if (!mounted) return;
    if (!confirmed) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).deleteAbsence(absence.id),
    );
    ref.invalidate(absencesByDateProvider(_date));
  }

  @override
  Widget build(BuildContext context) {
    final absences = ref.watch(absencesByDateProvider(_date));
    final types = ref.watch(absenceTypesProvider);
    ref.watch(usersProvider);
    return _AdminPage(
      title: 'Отсутствия',
      action: FilledButton.icon(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WorktimeCard(
            child: Row(
              children: [
                Expanded(
                  child: Text('Дата: ${ApiDate.formatDateOnly(_date)}'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Выбрать'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AsyncValueView(
            value: types,
            onRetry: () => ref.invalidate(absenceTypesProvider),
            data: (items) => WorktimeCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Типы отсутствий'),
                    subtitle: Text('${items.length} доступно'),
                    trailing: IconButton(
                      tooltip: 'Добавить тип',
                      onPressed: _createType,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  for (final type in items)
                    ListTile(
                      leading: const Icon(Icons.label_outline),
                      title: Text(type.name),
                      subtitle: Text(type.code),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Редактировать',
                            onPressed: () => _editType(type),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Удалить',
                            onPressed: () => _deleteType(type),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AsyncValueView(
            value: absences,
            onRetry: () => ref.invalidate(absencesTodayProvider),
            isEmpty: (items) => items.isEmpty,
            empty: const AppEmptyView(title: 'На сегодня отсутствий нет'),
            data: (items) => WorktimeCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in items)
                    ListTile(
                      leading: const Icon(Icons.beach_access_outlined),
                      title: Text(item.userId),
                      subtitle: Text(
                          '${ApiDate.formatDateOnly(item.dateFrom)} — ${ApiDate.formatDateOnly(item.dateTo)}'),
                      trailing: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(item.status.name),
                          IconButton(
                            tooltip: 'Отменить',
                            onPressed: item.status == AbsenceStatus.cancelled
                                ? null
                                : () => _cancel(item),
                            icon: const Icon(Icons.cancel_outlined),
                          ),
                          IconButton(
                            tooltip: 'Удалить',
                            onPressed: () => _delete(item),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCorrectionsScreen extends ConsumerStatefulWidget {
  const AdminCorrectionsScreen({super.key});

  @override
  ConsumerState<AdminCorrectionsScreen> createState() =>
      _AdminCorrectionsScreenState();
}

class _AdminCorrectionsScreenState
    extends ConsumerState<AdminCorrectionsScreen> {
  String? _userId;

  Future<void> _create() async {
    final users = ref.read(usersProvider).valueOrNull ?? const [];
    final data = await _correctionDialog(context, users: users);
    if (!mounted) return;
    if (data == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).createCorrection(data),
    );
    final targetUserId = data['user_id'] as String?;
    if (targetUserId != null) {
      setState(() => _userId = targetUserId);
      ref.invalidate(correctionsByUserProvider(targetUserId));
    }
  }

  Future<void> _cancel(TimeCorrection correction) async {
    final reason = await _textDialog(
      context,
      title: 'Отменить корректировку',
      label: 'Причина',
      actionLabel: 'Отменить',
      requiredValue: false,
    );
    if (!mounted) return;
    if (reason == null) return;
    await _runAdminAction(
      context,
      () => ref.read(worktimeApiProvider).cancelCorrection(
            correction.id,
            reason: reason,
          ),
    );
    ref.invalidate(correctionsByUserProvider(correction.userId));
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final currentUserId = ref.watch(authControllerProvider).userOrNull?.id;
    final selectedUserId = _userId ?? currentUserId;
    final corrections = selectedUserId == null
        ? const AsyncValue<List<TimeCorrection>>.data([])
        : ref.watch(correctionsByUserProvider(selectedUserId));
    return _AdminPage(
      title: 'Корректировки',
      action: FilledButton.icon(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsyncValueView(
            value: users,
            onRetry: () => ref.invalidate(usersProvider),
            data: (items) => WorktimeCard(
              child: DropdownButtonFormField<String>(
                initialValue: selectedUserId,
                decoration:
                    const InputDecoration(labelText: 'Пользователь для списка'),
                items: [
                  for (final user in items)
                    DropdownMenuItem(
                      value: user.id,
                      child: Text(user.fullName),
                    ),
                ],
                onChanged: (value) => setState(() => _userId = value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AsyncValueView(
            value: corrections,
            onRetry: selectedUserId == null
                ? null
                : () =>
                    ref.invalidate(correctionsByUserProvider(selectedUserId)),
            isEmpty: (items) => items.isEmpty,
            empty: const AppEmptyView(title: 'Корректировок пока нет'),
            data: (items) => WorktimeCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in items)
                    ListTile(
                      leading: const Icon(Icons.edit_calendar_outlined),
                      title: Text(ApiDate.formatDateOnly(item.workDate)),
                      subtitle: Text(item.reason),
                      trailing: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(item.status.name),
                          IconButton(
                            tooltip: 'Отменить',
                            onPressed: item.status == CorrectionStatus.cancelled
                                ? null
                                : () => _cancel(item),
                            icon: const Icon(Icons.cancel_outlined),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPage extends StatelessWidget {
  const _AdminPage({
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return WorktimePage(
      title: title,
      subtitle: 'Администрирование Worktime',
      actions: [
        if (action != null)
          Padding(padding: const EdgeInsets.only(right: 8), child: action!),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: '/admin/users',
                    label: Text('Пользователи'),
                    icon: Icon(Icons.people_outline)),
                ButtonSegment(
                    value: '/admin/departments',
                    label: Text('Отделы'),
                    icon: Icon(Icons.apartment_outlined)),
                ButtonSegment(
                    value: '/admin/schedules',
                    label: Text('Графики'),
                    icon: Icon(Icons.event_repeat_outlined)),
                ButtonSegment(
                    value: '/admin/absences',
                    label: Text('Отсутствия'),
                    icon: Icon(Icons.beach_access_outlined)),
                ButtonSegment(
                    value: '/admin/corrections',
                    label: Text('Корректировки'),
                    icon: Icon(Icons.edit_calendar_outlined)),
              ],
              selected: {GoRouterState.of(context).uri.path},
              onSelectionChanged: (value) => context.go(value.single),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CalendarDayRow extends StatelessWidget {
  const _CalendarDayRow({required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
          Icon(day.isWorking ? Icons.work_outline : Icons.weekend_outlined),
      title: Text(ApiDate.formatDateOnly(day.date)),
      subtitle: Text(_dayStatus(day)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(ApiDuration.formatHm(day.workedSeconds)),
          Text(
            'из ${ApiDuration.formatHm(day.expectedSeconds)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Обновить',
      onPressed: onPressed,
      icon: const Icon(Icons.refresh),
    );
  }
}

Future<void> _runAdminAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Изменения сохранены')),
    );
  } on Object catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ErrorMapper.map(e).message)),
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Подтвердить'),
            ),
          ],
        ),
      ) ??
      false;
}

Future<String?> _textDialog(
  BuildContext context, {
  required String title,
  required String label,
  String actionLabel = 'Создать',
  bool requiredValue = true,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена')),
        FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (requiredValue && value.isEmpty) return;
              Navigator.pop(context, value);
            },
            child: Text(actionLabel)),
      ],
    ),
  );
}

Future<_DepartmentFormData?> _departmentDialog(
  BuildContext context, {
  required List<Department> departments,
  Department? initial,
}) {
  final name = TextEditingController(text: initial?.name ?? '');
  String? parentId = initial?.parentId;
  return showDialog<_DepartmentFormData>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initial == null ? 'Новый отдел' : 'Редактировать отдел'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: parentId,
              decoration: const InputDecoration(labelText: 'Родитель'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Нет'),
                ),
                for (final department in departments)
                  DropdownMenuItem<String?>(
                    value: department.id,
                    child: Text(department.name),
                  ),
              ],
              onChanged: (value) => setState(() => parentId = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final value = name.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(
                context,
                _DepartmentFormData(name: value, parentId: parentId),
              );
            },
            child: Text(initial == null ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    ),
  );
}

Future<_OrganizationFormData?> _organizationDialog(
  BuildContext context, {
  required List<Department> departments,
  required List<UserProfile> users,
}) {
  String? departmentId;
  String? managerId;
  return showDialog<_OrganizationFormData>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Организация пользователя'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String?>(
              initialValue: departmentId,
              decoration: const InputDecoration(labelText: 'Отдел'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Без отдела'),
                ),
                for (final department in departments)
                  DropdownMenuItem<String?>(
                    value: department.id,
                    child: Text(department.name),
                  ),
              ],
              onChanged: (value) => setState(() => departmentId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: managerId,
              decoration: const InputDecoration(labelText: 'Менеджер'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Без менеджера'),
                ),
                for (final user in users)
                  if (user.isManager || user.isAdmin)
                    DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text(user.fullName),
                    ),
              ],
              onChanged: (value) => setState(() => managerId = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _OrganizationFormData(
                departmentId: departmentId,
                managerId: managerId,
              ),
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> _scheduleDialog(
  BuildContext context, {
  WorkSchedule? initial,
}) {
  final name = TextEditingController(text: initial?.name ?? '');
  final timezone =
      TextEditingController(text: initial?.timezone ?? 'Europe/Moscow');
  final startGrace = TextEditingController(
    text: ((initial?.startGraceSeconds ?? 900) ~/ 60).toString(),
  );
  final stopGrace = TextEditingController(
    text: ((initial?.stopGraceSeconds ?? 900) ~/ 60).toString(),
  );
  var type = initial?.scheduleType ?? ScheduleType.weekly;
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initial == null ? 'Новый график' : 'Редактировать график'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ScheduleType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Тип'),
                items: [
                  for (final item in ScheduleType.values)
                    DropdownMenuItem(value: item, child: Text(item.name)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => type = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timezone,
                decoration: const InputDecoration(labelText: 'Часовой пояс'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: startGrace,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Допуск старта, минуты'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stopGrace,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Допуск завершения, минуты'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final scheduleName = name.text.trim();
              final tz = timezone.text.trim();
              if (scheduleName.isEmpty || tz.isEmpty) return;
              Navigator.pop(context, {
                'name': scheduleName,
                'schedule_type': type.name,
                'timezone': tz,
                'start_grace_seconds':
                    (int.tryParse(startGrace.text.trim()) ?? 0) * 60,
                'stop_grace_seconds':
                    (int.tryParse(stopGrace.text.trim()) ?? 0) * 60,
              });
            },
            child: Text(initial == null ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> _scheduleDayDialog(
  BuildContext context, {
  WorkScheduleDay? initial,
}) {
  final startSeconds =
      ApiDuration.nanosToSeconds(initial?.startTime) ?? 9 * 3600;
  final endSeconds = ApiDuration.nanosToSeconds(initial?.endTime) ?? 18 * 3600;
  final start = TextEditingController(text: (startSeconds ~/ 3600).toString());
  final end = TextEditingController(text: (endSeconds ~/ 3600).toString());
  final breakMinutes = TextEditingController(
    text: ((initial?.breakSeconds ?? 3600) ~/ 60).toString(),
  );
  final expectedHours = TextEditingController(
    text: ((initial?.expectedSeconds ?? 28800) ~/ 3600).toString(),
  );
  var weekday = initial?.weekday ?? 1;
  var isWorking = initial?.isWorking ?? true;
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initial == null
            ? 'Новый день графика'
            : 'Редактировать день графика'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: weekday,
                decoration: const InputDecoration(labelText: 'День недели'),
                items: [
                  for (var day = 1; day <= 7; day++)
                    DropdownMenuItem(value: day, child: Text('День $day')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => weekday = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Рабочий день'),
                value: isWorking,
                onChanged: (value) => setState(() => isWorking = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: start,
                enabled: isWorking,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Старт, час'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: end,
                enabled: isWorking,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Финиш, час'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: breakMinutes,
                enabled: isWorking,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Перерыв, минуты'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: expectedHours,
                enabled: isWorking,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'План, часы'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final startHour = int.tryParse(start.text.trim()) ?? 9;
              final endHour = int.tryParse(end.text.trim()) ?? 18;
              Navigator.pop(context, {
                'weekday': weekday,
                'is_working': isWorking,
                'start_time_seconds': isWorking ? startHour * 3600 : null,
                'end_time_seconds': isWorking ? endHour * 3600 : null,
                'break_seconds': isWorking
                    ? (int.tryParse(breakMinutes.text.trim()) ?? 0) * 60
                    : 0,
                'expected_seconds': isWorking
                    ? (int.tryParse(expectedHours.text.trim()) ?? 0) * 3600
                    : 0,
              });
            },
            child: Text(initial == null ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> _scheduleAssignmentDialog(
  BuildContext context, {
  required List<UserProfile> users,
  required WorkSchedule schedule,
}) {
  String? userId = users.firstOrNull?.id;
  final validFrom =
      TextEditingController(text: ApiDate.formatDateOnly(DateTime.now()));
  final validTo = TextEditingController();
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Назначить ${schedule.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: userId,
              decoration: const InputDecoration(labelText: 'Пользователь'),
              items: [
                for (final user in users)
                  DropdownMenuItem(value: user.id, child: Text(user.fullName)),
              ],
              onChanged: (value) => setState(() => userId = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: validFrom,
              decoration: const InputDecoration(labelText: 'С YYYY-MM-DD'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: validTo,
              decoration: const InputDecoration(labelText: 'По YYYY-MM-DD'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (userId == null || validFrom.text.trim().isEmpty) return;
              Navigator.pop(context, {
                'user_id': userId,
                'schedule_id': schedule.id,
                'valid_from': validFrom.text.trim(),
                'valid_to': validTo.text.trim(),
              });
            },
            child: const Text('Назначить'),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> _absenceDialog(
  BuildContext context, {
  required List<UserProfile> users,
  required List<AbsenceType> types,
}) {
  String? userId = users.firstOrNull?.id;
  String? typeId = types.firstOrNull?.id;
  var dayPart = AbsenceDayPart.fullDay;
  final from =
      TextEditingController(text: ApiDate.formatDateOnly(DateTime.now()));
  final to =
      TextEditingController(text: ApiDate.formatDateOnly(DateTime.now()));
  final reason = TextEditingController();
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Новое отсутствие'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: userId,
                decoration: const InputDecoration(labelText: 'Пользователь'),
                items: [
                  for (final user in users)
                    DropdownMenuItem(
                        value: user.id, child: Text(user.fullName)),
                ],
                onChanged: (value) => setState(() => userId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: typeId,
                decoration: const InputDecoration(labelText: 'Тип отсутствия'),
                items: [
                  for (final type in types)
                    DropdownMenuItem(value: type.id, child: Text(type.name)),
                ],
                onChanged: (value) => setState(() => typeId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AbsenceDayPart>(
                initialValue: dayPart,
                decoration: const InputDecoration(labelText: 'Часть дня'),
                items: [
                  for (final item in AbsenceDayPart.values)
                    DropdownMenuItem(value: item, child: Text(item.name)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => dayPart = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: from,
                decoration:
                    const InputDecoration(labelText: 'Дата начала YYYY-MM-DD'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: to,
                decoration: const InputDecoration(
                    labelText: 'Дата окончания YYYY-MM-DD'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Причина'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (userId == null || typeId == null) return;
              Navigator.pop(context, {
                'user_id': userId,
                'absence_type_id': typeId,
                'date_from': from.text.trim(),
                'date_to': to.text.trim(),
                'day_part': _absenceDayPartWire(dayPart),
                'reason': reason.text.trim(),
              });
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> _correctionDialog(
  BuildContext context, {
  required List<UserProfile> users,
}) {
  String? userId = users.firstOrNull?.id;
  final workDate =
      TextEditingController(text: ApiDate.formatDateOnly(DateTime.now()));
  final reason = TextEditingController();
  final workedSeconds = TextEditingController(text: '28800');
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Новая корректировка'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: userId,
                decoration: const InputDecoration(labelText: 'Пользователь'),
                items: [
                  for (final user in users)
                    DropdownMenuItem(
                        value: user.id, child: Text(user.fullName)),
                ],
                onChanged: (value) => setState(() => userId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: workDate,
                decoration: const InputDecoration(labelText: 'Дата YYYY-MM-DD'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: workedSeconds,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Новое значение, секунды'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Причина'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (userId == null || reason.text.trim().isEmpty) return;
              Navigator.pop(context, {
                'user_id': userId,
                'session_id': null,
                'work_date': workDate.text.trim(),
                'new_value': {
                  'worked_seconds':
                      int.tryParse(workedSeconds.text.trim()) ?? 0,
                },
                'reason': reason.text.trim(),
                'created_time_event_id': null,
              });
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> _absenceTypeDialog(
  BuildContext context, {
  AbsenceType? initial,
}) {
  final code = TextEditingController(text: initial?.code ?? '');
  final name = TextEditingController(text: initial?.name ?? '');
  var affectsWorkPlan = initial?.affectsWorkPlan ?? true;
  var requiresDocument = initial?.requiresDocument ?? false;
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initial == null
            ? 'Новый тип отсутствия'
            : 'Редактировать тип отсутствия'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: code,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Код'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Влияет на план'),
              value: affectsWorkPlan,
              onChanged: (value) => setState(() => affectsWorkPlan = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Требует документ'),
              value: requiresDocument,
              onChanged: (value) => setState(() => requiresDocument = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final typeCode = code.text.trim();
              final typeName = name.text.trim();
              if (typeCode.isEmpty || typeName.isEmpty) return;
              Navigator.pop(context, {
                'code': typeCode,
                'name': typeName,
                'affects_work_plan': affectsWorkPlan,
                'requires_document': requiresDocument,
              });
            },
            child: Text(initial == null ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    ),
  );
}

Future<_PasswordFormData?> _passwordDialog(BuildContext context) {
  final current = TextEditingController();
  final next = TextEditingController();
  return showDialog<_PasswordFormData>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Сменить пароль'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: current,
            autofocus: true,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Текущий пароль'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: next,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Новый пароль'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            if (current.text.isEmpty || next.text.length < 8) return;
            Navigator.pop(
              context,
              _PasswordFormData(
                currentPassword: current.text,
                newPassword: next.text,
              ),
            );
          },
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
}

class _DepartmentFormData {
  const _DepartmentFormData({required this.name, this.parentId});

  final String name;
  final String? parentId;
}

class _OrganizationFormData {
  const _OrganizationFormData({this.departmentId, this.managerId});

  final String? departmentId;
  final String? managerId;
}

class _PasswordFormData {
  const _PasswordFormData({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

String _absenceDayPartWire(AbsenceDayPart value) {
  switch (value) {
    case AbsenceDayPart.fullDay:
      return 'full_day';
    case AbsenceDayPart.firstHalf:
      return 'first_half';
    case AbsenceDayPart.secondHalf:
      return 'second_half';
    case AbsenceDayPart.customTime:
      return 'custom_time';
  }
}

String _sessionLabel(WorkSession? session) {
  if (session == null) return 'Не начат';
  switch (session.status) {
    case WorkSessionStatus.working:
      return 'Работает';
    case WorkSessionStatus.paused:
      return 'Пауза';
    case WorkSessionStatus.finished:
      return 'Завершен';
    case WorkSessionStatus.incomplete:
      return 'Неполный';
  }
}

IconData _statusIcon(WorkSessionStatus? status) {
  switch (status) {
    case WorkSessionStatus.working:
      return Icons.play_circle_fill;
    case WorkSessionStatus.paused:
      return Icons.pause_circle_filled;
    case WorkSessionStatus.finished:
      return Icons.check_circle;
    case WorkSessionStatus.incomplete:
      return Icons.error;
    case null:
      return Icons.timer_outlined;
  }
}

String _dayStatus(CalendarDay day) {
  final status = day.dayStatus?.name ?? (day.isWorking ? 'workday' : 'day_off');
  final source = day.planSource?.name;
  return source == null ? status : '$status · $source';
}

String _memberStatus(TeamMemberState employee) {
  return employee.sessionStatus?.name ??
      employee.todayDayStatus?.name ??
      'нет сессии';
}
