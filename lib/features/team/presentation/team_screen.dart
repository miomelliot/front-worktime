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
        if (state.restricted) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Команда',
                description:
                    'Кто сейчас работает — статусы и часы по отделам.',
              ),
              EmptyState(
                title: 'Директория недоступна',
                message:
                    'Список команды виден только руководителям и '
                    'администраторам — для вашей роли API его не отдаёт.',
              ),
            ],
          );
        }
        final controller = ref.read(teamControllerProvider.notifier);
        final filtered = state.filtered;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Команда',
              description: 'Кто сейчас работает — статусы и часы по отделам.',
            ),
            // Scoped to just the stat tiles (not the whole screen) — a
            // LayoutBuilder wrapping the ShadInput search field below would
            // race with GoRouter's navigation on tile tap and crash with
            // "_debugRelayoutBoundaryAlreadyMarkedNeedsLayout" when the
            // EditableText gets torn down mid-layout-callback.
            LayoutBuilder(
              builder: (context, constraints) => _StatsRow(
                employees: state.employees,
                wide: constraints.maxWidth >= 980,
              ),
            ),
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
                message: 'Попробуйте изменить поиск или сбросить фильтры.',
              )
            else
              _DepartmentGroups(groups: state.filteredByDepartment),
          ],
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
    final departmentOptions = [teamFilterAll, ...state.availableDepartments];
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

class _DepartmentGroups extends StatelessWidget {
  const _DepartmentGroups({required this.groups});

  final List<TeamDepartmentGroup> groups;

  @override
  Widget build(BuildContext context) {
    // A lone "Без отдела" bucket means department just isn't resolvable for
    // this viewer's role (e.g. an admin's global user list) rather than a
    // real grouping choice — showing that as a heading would be misleading.
    final showHeaders = groups.length > 1 ||
        (groups.isNotEmpty && groups.first.name != 'Без отдела');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xl),
          _DepartmentGroupSection(group: groups[i], showHeader: showHeaders),
        ],
      ],
    );
  }
}

class _DepartmentGroupSection extends StatelessWidget {
  const _DepartmentGroupSection({required this.group, required this.showHeader});

  final TeamDepartmentGroup group;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              Text(
                group.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '· ${group.employees.length}',
                style: TextStyle(fontSize: 13, color: colors.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final employee in group.employees)
              SizedBox(
                width: 220,
                child: EmployeeStatusTile(
                  employee: employee,
                  onTap: () => context.go('/team/${employee.user.id}'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
