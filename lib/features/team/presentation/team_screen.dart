import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../today/domain/work_status.dart';
import '../application/team_controller.dart';
import '../domain/employee_status.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamControllerProvider);
    return team.when(
      loading: () => const LoadingState(label: 'Загружаем команду'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) {
        final controller = ref.read(teamControllerProvider.notifier);
        final filtered = state.filtered;
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Команда',
                  description:
                      'Кто сейчас работает — статусы и часы по отделам.',
                ),
                _StatsRow(employees: state.employees, wide: wide),
                const SizedBox(height: AppSpacing.xl),
                _FiltersBar(state: state, controller: controller),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'Показано ${filtered.length} из ${state.employees.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const EmptyState(
                    title: 'Никого не найдено',
                    message:
                        'Попробуйте изменить поиск или сбросить фильтры.',
                  )
                else if (wide)
                  EmployeeStatusTable(
                    employees: filtered,
                    onOpen: (employee) => context.go('/team/${employee.user.id}'),
                  )
                else
                  _CardGrid(employees: filtered, maxWidth: constraints.maxWidth),
              ],
            );
          },
        );
      },
    );
  }
}

/// Four at-a-glance counts over the whole team, unaffected by the filters
/// below — always shows the true headcount so filtering doesn't hide it.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.employees, required this.wide});

  final List<EmployeeStatus> employees;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final working =
        employees.where((e) => e.status == WorkStatus.working).length;
    final paused =
        employees.where((e) => e.status == WorkStatus.paused).length;
    final away = employees.length - working - paused;

    final tiles = [
      StatTile(
        icon: LucideIcons.users,
        accent: AppColors.brand,
        title: 'Всего в команде',
        value: '${employees.length}',
        suffix: 'человек',
      ),
      StatTile(
        icon: LucideIcons.zap,
        accent: AppColors.statusWorkingText,
        title: 'Работают сейчас',
        value: '$working',
        suffix: 'онлайн',
      ),
      StatTile(
        icon: LucideIcons.coffee,
        accent: AppColors.statusPausedText,
        title: 'На паузе',
        value: '$paused',
        suffix: 'человек',
      ),
      StatTile(
        icon: LucideIcons.moon,
        accent: AppColors.muted,
        title: 'Не на смене',
        value: '$away',
        suffix: 'выходной / отпуск / завершили',
      ),
    ];

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
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

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({required this.state, required this.controller});

  final TeamState state;
  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final departmentOptions = [
      teamFilterAll,
      ...state.departments.map((department) => department.name),
    ];
    final statusOptions = [teamFilterAll, ...state.availableStatuses];

    return DashboardCard(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: ShadInput(
              key: ValueKey('search-${state.filtersEpoch}'),
              placeholder: const Text('Поиск по имени или почте'),
              leading: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(LucideIcons.search, size: 16),
              ),
              initialValue: state.query,
              onChanged: controller.setQuery,
            ),
          ),
          _FilterSelect(
            key: ValueKey('department-${state.department}'),
            placeholder: 'Отдел',
            value: state.department,
            options: departmentOptions,
            onChanged: controller.setDepartment,
          ),
          _FilterSelect(
            key: ValueKey('status-${state.status}'),
            placeholder: 'Статус',
            value: state.status,
            options: statusOptions,
            onChanged: controller.setStatus,
          ),
          if (state.hasActiveFilters)
            ShadButton.ghost(
              leading: const Icon(LucideIcons.x, size: 14),
              onPressed: controller.resetFilters,
              child: const Text('Сбросить'),
            ),
        ],
      ),
    );
  }
}

class _FilterSelect extends StatelessWidget {
  const _FilterSelect({
    super.key,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String placeholder;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ShadSelect<String>(
      minWidth: 180,
      initialValue: value,
      placeholder: Text(placeholder),
      selectedOptionBuilder: (context, selected) => Text(selected),
      onChanged: (selected) => onChanged(selected ?? teamFilterAll),
      options: [
        for (final option in options)
          ShadOption(value: option, child: Text(option)),
      ],
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.employees, required this.maxWidth});

  final List<EmployeeStatus> employees;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final columns = maxWidth >= 640 ? 2 : 1;
    final cardWidth =
        columns == 1 ? maxWidth : (maxWidth - AppSpacing.lg) / columns;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        for (final employee in employees)
          SizedBox(
            width: cardWidth,
            child: EmployeeStatusCard(
              employee: employee,
              onOpen: () => context.go('/team/${employee.user.id}'),
            ),
          ),
      ],
    );
  }
}
