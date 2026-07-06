import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../application/team_controller.dart';

class EmployeeDetailsScreen extends ConsumerWidget {
  const EmployeeDetailsScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamControllerProvider);
    return team.when(
      loading: () => const LoadingState(label: 'Загружаем сотрудника'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) {
        final employee = state.employees
            .where((item) => item.user.id == userId)
            .firstOrNull;
        if (employee == null) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackButton(),
              SizedBox(height: AppSpacing.lg),
              EmptyState(
                title: 'Сотрудник не найден',
                message: 'В доступном вам списке команды нет такого id.',
              ),
            ],
          );
        }
        final user = employee.user;
        final subtitle = [
          if (user.title?.isNotEmpty ?? false) user.title!,
          if (user.department != null) user.department!,
        ].join(' · ');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BackButton(),
            const SizedBox(height: AppSpacing.lg),
            PageHeader(
              title: user.name,
              description: subtitle.isEmpty ? user.email : subtitle,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 780;
                final cards = <Widget>[
                  EmployeeStatusCard(employee: employee),
                  if (employee.plan != null)
                    WorkdayPlanCard(plan: employee.plan!)
                  else
                    const EmptyState(
                      title: 'План не задан',
                      message: 'На сегодня для сотрудника нет графика.',
                    ),
                  MetricCard(
                    icon: LucideIcons.timer,
                    label: 'Отработано сегодня',
                    value: '${employee.actualHours.toStringAsFixed(1)} ч',
                    caption: employee.plannedHours > 0
                        ? 'из ${employee.plannedHours.toStringAsFixed(1)} ч по плану'
                        : employee.lastEvent,
                  ),
                  const EmptyState(
                    title: 'Отсутствия',
                    message: 'Скоро — история отпусков и больничных.',
                  ),
                  const EmptyState(
                    title: 'Нарушения',
                    message: 'Скоро — опоздания и недоработки.',
                  ),
                  const EmptyState(
                    title: 'Корректировки',
                    message: 'Скоро — ручные правки рабочего времени.',
                  ),
                ];
                return Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.lg,
                  children: [
                    for (final card in cards)
                      SizedBox(
                        width: wide ? 360 : double.infinity,
                        child: card,
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      leading: const Icon(LucideIcons.arrowLeft, size: 16),
      onPressed: () => context.go('/team'),
      child: const Text('Назад к команде'),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
