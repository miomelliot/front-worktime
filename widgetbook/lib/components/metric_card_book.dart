import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/shared/ui/metric_card.dart';

final metricCardBook = WidgetbookComponent(
  name: 'MetricCard',
  useCases: [
    WidgetbookUseCase.child(
        name: 'users',
        child: const MetricCard(
            label: 'Users',
            value: '42',
            caption: 'Active accounts',
            icon: LucideIcons.users)),
    WidgetbookUseCase.child(
        name: 'working now',
        child: const MetricCard(
            label: 'Working now',
            value: '18',
            caption: 'Live sessions',
            icon: LucideIcons.timer)),
    WidgetbookUseCase.child(
        name: 'departments',
        child: const MetricCard(
            label: 'Departments',
            value: '4',
            caption: 'Org units',
            icon: LucideIcons.building2)),
    WidgetbookUseCase.child(
        name: 'schedules',
        child: const MetricCard(
            label: 'Schedules',
            value: '3',
            caption: 'Templates',
            icon: LucideIcons.clock)),
  ],
);
