import '../../auth/domain/app_user.dart';
import '../../today/domain/work_status.dart';

class EmployeeStatus {
  const EmployeeStatus({
    required this.user,
    required this.status,
    required this.plannedHours,
    required this.actualHours,
    required this.lastEvent,
  });

  final AppUser user;
  final WorkStatus status;
  final double plannedHours;
  final double actualHours;
  final String lastEvent;
}
