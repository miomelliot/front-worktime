import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dio/dio_client.dart';
import '../../../core/utils/date_formats.dart';
import '../../auth/domain/user_profile.dart';
import '../domain/worktime_models.dart';

class WorktimeApi {
  WorktimeApi(this._dio);

  final Dio _dio;

  Future<UserProfile> updateMe({
    required String fullName,
    required String timezone,
    String? position,
    String? avatarUrl,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/me',
      data: {
        'full_name': fullName,
        'timezone': timezone,
        if (position != null) 'position': position,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );
    return UserProfile.fromJson(response.data!);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '/users/me/password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<List<UserProfile>> users() async {
    final response = await _dio.get<List<dynamic>>('/users');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(UserProfile.fromJson)
        .toList();
  }

  Future<UserProfile> updateUserRole({
    required String id,
    required String role,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id/role',
      data: {'role': role},
    );
    return UserProfile.fromJson(response.data!);
  }

  Future<void> deleteUser(String id) => _dio.delete<void>('/users/$id');

  Future<UserOrganization> assignUserOrganization({
    required String userId,
    String? departmentId,
    String? managerId,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$userId/organization',
      data: {
        'department_id': departmentId,
        'manager_id': managerId,
      },
    );
    return UserOrganization.fromJson(response.data!);
  }

  Future<List<Department>> departments() async {
    final response = await _dio.get<List<dynamic>>('/departments');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Department.fromJson)
        .toList();
  }

  Future<Department> createDepartment({
    required String name,
    String? parentId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/departments',
      data: {
        'name': name,
        'parent_id': parentId,
      },
    );
    return Department.fromJson(response.data!);
  }

  Future<Department> updateDepartment({
    required String id,
    required String name,
    String? parentId,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/departments/$id',
      data: {
        'name': name,
        'parent_id': parentId,
      },
    );
    return Department.fromJson(response.data!);
  }

  Future<void> deleteDepartment(String id) =>
      _dio.delete<void>('/departments/$id');

  Future<WorkSession?> todaySession(String userId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/time-tracking/session',
        queryParameters: {
          'user_id': userId,
          'work_date': ApiDate.todayDateOnly(),
        },
      );
      return WorkSession.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<TrackingResult> timeAction({
    required String action,
    required String userId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/time-tracking/$action',
      data: {'user_id': userId},
    );
    return TrackingResult.fromJson(response.data!);
  }

  Future<EmployeeCalendar> employeeCalendar({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/work-state/users/$userId/calendar',
      queryParameters: {
        'from': ApiDate.formatDateOnly(from),
        'to': ApiDate.formatDateOnly(to),
      },
    );
    return EmployeeCalendar.fromJson(response.data!);
  }

  Future<DepartmentsState> departmentsState() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/work-state/departments');
    return DepartmentsState.fromJson(response.data!);
  }

  Future<TeamState> teamState(String managerId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/work-state/managers/$managerId/team');
    return TeamState.fromJson(response.data!);
  }

  Future<List<WorkingNowItem>> workingNow() async {
    final response = await _dio.get<List<dynamic>>('/work-state/working-now');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(WorkingNowItem.fromJson)
        .toList();
  }

  Future<ViolationSummary> violationSummary({String? userId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/work-state/violations/summary',
      queryParameters: {if (userId != null) 'user_id': userId},
    );
    return ViolationSummary.fromJson(response.data!);
  }

  Future<List<WorkSchedule>> schedules() async {
    final response = await _dio.get<List<dynamic>>('/schedules');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(WorkSchedule.fromJson)
        .toList();
  }

  Future<WorkSchedule> createSchedule(Map<String, dynamic> data) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/schedules', data: data);
    return WorkSchedule.fromJson(response.data!);
  }

  Future<WorkSchedule> updateSchedule(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _dio.patch<Map<String, dynamic>>('/schedules/$id', data: data);
    return WorkSchedule.fromJson(response.data!);
  }

  Future<void> deleteSchedule(String id) => _dio.delete<void>('/schedules/$id');

  Future<List<WorkScheduleDay>> scheduleDays(String scheduleId) async {
    final response =
        await _dio.get<List<dynamic>>('/schedules/$scheduleId/days');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(WorkScheduleDay.fromJson)
        .toList();
  }

  Future<WorkScheduleDay> createScheduleDay({
    required String scheduleId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/schedules/$scheduleId/days',
      data: data,
    );
    return WorkScheduleDay.fromJson(response.data!);
  }

  Future<WorkScheduleDay> updateScheduleDay({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/schedule-days/$id',
      data: data,
    );
    return WorkScheduleDay.fromJson(response.data!);
  }

  Future<void> deleteScheduleDay(String id) =>
      _dio.delete<void>('/schedule-days/$id');

  Future<ScheduleAssignment> createScheduleAssignment(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/schedule-assignments',
      data: data,
    );
    return ScheduleAssignment.fromJson(response.data!);
  }

  Future<ScheduleAssignment> updateScheduleAssignment({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/schedule-assignments/$id',
      data: data,
    );
    return ScheduleAssignment.fromJson(response.data!);
  }

  Future<void> deleteScheduleAssignment(String id) =>
      _dio.delete<void>('/schedule-assignments/$id');

  Future<List<AbsenceType>> absenceTypes() async {
    final response = await _dio.get<List<dynamic>>('/absence-types');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(AbsenceType.fromJson)
        .toList();
  }

  Future<AbsenceType> createAbsenceType(Map<String, dynamic> data) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/absence-types', data: data);
    return AbsenceType.fromJson(response.data!);
  }

  Future<AbsenceType> updateAbsenceType(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/absence-types/$id',
      data: data,
    );
    return AbsenceType.fromJson(response.data!);
  }

  Future<void> deleteAbsenceType(String id) =>
      _dio.delete<void>('/absence-types/$id');

  Future<List<Absence>> absencesByDate(DateTime date) async {
    final response = await _dio.get<List<dynamic>>(
      '/absences',
      queryParameters: {'date': ApiDate.formatDateOnly(date)},
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Absence.fromJson)
        .toList();
  }

  Future<Absence> createAbsence(Map<String, dynamic> data) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/absences', data: data);
    return Absence.fromJson(response.data!);
  }

  Future<Absence> updateAbsence(String id, Map<String, dynamic> data) async {
    final response =
        await _dio.patch<Map<String, dynamic>>('/absences/$id', data: data);
    return Absence.fromJson(response.data!);
  }

  Future<Absence> cancelAbsence(String id, {String? reason}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/absences/$id/cancel',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return Absence.fromJson(response.data!);
  }

  Future<void> deleteAbsence(String id) => _dio.delete<void>('/absences/$id');

  Future<List<TimeCorrection>> userCorrections(String userId) async {
    final response =
        await _dio.get<List<dynamic>>('/users/$userId/corrections');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(TimeCorrection.fromJson)
        .toList();
  }

  Future<TimeCorrection> createCorrection(Map<String, dynamic> data) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/corrections', data: data);
    return TimeCorrection.fromJson(response.data!);
  }

  Future<TimeCorrection> cancelCorrection(String id, {String? reason}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/corrections/$id/cancel',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return TimeCorrection.fromJson(response.data!);
  }
}

final worktimeApiProvider = Provider<WorktimeApi>((ref) {
  return WorktimeApi(ref.watch(dioProvider));
});
