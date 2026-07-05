import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/features/auth/domain/user_role.dart';
import 'package:worktime/features/today/domain/work_status.dart';
import 'package:worktime/shared/ui/role_badge.dart';
import 'package:worktime/shared/ui/status_badge.dart';

final statusBadgeBook = WidgetbookComponent(
  name: 'StatusBadge',
  useCases: [
    for (final status in [
      WorkStatus.working,
      WorkStatus.paused,
      WorkStatus.notStarted,
      WorkStatus.stopped,
      WorkStatus.dayOff,
      WorkStatus.holiday,
      WorkStatus.shortened,
    ])
      WidgetbookUseCase.child(
          name: status.label,
          child: Center(child: StatusBadge(status: status))),
  ],
);

final roleBadgeBook = WidgetbookComponent(
  name: 'RoleBadge',
  useCases: [
    for (final role in UserRole.values)
      WidgetbookUseCase.child(
          name: role.label, child: Center(child: RoleBadge(role: role))),
  ],
);
