import '../../../shared/mock/mock_workday.dart';
import '../domain/work_session.dart';

class FakeTodayRepository {
  Future<WorkSession> loadToday() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return mockTodaySession;
  }
}
