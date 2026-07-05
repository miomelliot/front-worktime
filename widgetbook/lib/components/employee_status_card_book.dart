import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/features/today/domain/work_status.dart';
import 'package:worktime/shared/mock/mock_workday.dart';
import 'package:worktime/shared/ui/employee_status_card.dart';

final employeeStatusCardBook = WidgetbookComponent(
  name: 'EmployeeStatusCard',
  useCases: [
    for (final employee in mockEmployeeStatuses)
      WidgetbookUseCase.child(
        name: employee.status.label,
        child: EmployeeStatusCard(employee: employee, onOpen: () {}),
      ),
  ],
);
