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
