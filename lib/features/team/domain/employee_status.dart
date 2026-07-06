import '../../auth/domain/app_user.dart';
import '../../today/domain/work_status.dart';
import '../../today/domain/workday_plan.dart';

class EmployeeStatus {
  const EmployeeStatus({
    required this.user,
    required this.status,
    required this.plannedHours,
    required this.actualHours,
    required this.lastEvent,
    this.plan,
  });

  final AppUser user;
  final WorkStatus status;
  final double plannedHours;
  final double actualHours;
  final String lastEvent;

  /// Today's real workday plan — only populated when sourced from the live
  /// backend (see `TeamRepository`); null for mock data, which builds its
  /// own ad-hoc plan on the details screen.
  final WorkdayPlan? plan;
}
