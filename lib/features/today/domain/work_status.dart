enum WorkStatus {
  working,
  paused,
  notStarted,
  stopped,
  /// Session ended without a proper stop (e.g. forgot to clock out) — the
  /// backend's `incomplete` time-tracking status. Distinct from [stopped]
  /// so it doesn't read as a normally-completed day.
  incomplete,
  dayOff,
  holiday,
  shortened,
  vacationDisplayOnly,
  sickDisplayOnly,
}

/// Maps a `GET /time-tracking/session` response (null when the backend
/// 404s — no session started yet) to a [WorkStatus]. Shared by the Today
/// and Team features so a "working"/"paused"/etc. session always reads the
/// same way everywhere.
WorkStatus workStatusFromSession(
  Map<String, dynamic>? session, {
  required bool isDayOff,
}) {
  switch (session?['status'] as String?) {
    case 'working':
      return WorkStatus.working;
    case 'paused':
      return WorkStatus.paused;
    case 'finished':
      return WorkStatus.stopped;
    case 'incomplete':
      return WorkStatus.incomplete;
  }
  return isDayOff ? WorkStatus.dayOff : WorkStatus.notStarted;
}

extension WorkStatusLabel on WorkStatus {
  String get label {
    switch (this) {
      case WorkStatus.working:
        return 'Работает';
      case WorkStatus.paused:
        return 'Пауза';
      case WorkStatus.notStarted:
        return 'Не начат';
      case WorkStatus.stopped:
        return 'Завершен';
      case WorkStatus.incomplete:
        return 'Не завершен';
      case WorkStatus.dayOff:
        return 'Выходной';
      case WorkStatus.holiday:
        return 'Праздник';
      case WorkStatus.shortened:
        return 'Сокращенный';
      case WorkStatus.vacationDisplayOnly:
        return 'Отпуск';
      case WorkStatus.sickDisplayOnly:
        return 'Больничный';
    }
  }
}
