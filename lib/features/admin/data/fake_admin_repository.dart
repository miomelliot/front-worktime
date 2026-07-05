import '../../../shared/mock/mock_departments.dart';
import '../../../shared/mock/mock_users.dart';

class ScheduleInfo {
  const ScheduleInfo({
    required this.name,
    required this.type,
    required this.timezone,
    required this.grace,
    required this.summary,
  });

  final String name;
  final String type;
  final String timezone;
  final String grace;
  final String summary;
}

class FakeAdminRepository {
  Future<AdminSnapshot> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const AdminSnapshot();
  }
}

class AdminSnapshot {
  const AdminSnapshot();

  int get totalUsers => mockUsers.length;
  int get departments => mockDepartments.length;
  int get workingNow => 2;
  int get activeSchedules => schedules.length;

  List<ScheduleInfo> get schedules => const [
        ScheduleInfo(
            name: 'Standard 5/2',
            type: 'weekly',
            timezone: 'Europe/Moscow',
            grace: '10 / 10 min',
            summary: 'Mon-Fri, 09:00-18:00'),
        ScheduleInfo(
            name: 'Flexible',
            type: 'flexible',
            timezone: 'Europe/Moscow',
            grace: '20 / 20 min',
            summary: '8h daily, floating start'),
        ScheduleInfo(
            name: 'Shift 2/2',
            type: 'shift',
            timezone: 'Europe/Moscow',
            grace: '15 / 15 min',
            summary: 'Two days on, two days off'),
      ];
}
