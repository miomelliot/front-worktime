enum WorkStatus {
  working,
  paused,
  notStarted,
  stopped,
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
