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
        return 'Working';
      case WorkStatus.paused:
        return 'Paused';
      case WorkStatus.notStarted:
        return 'Not started';
      case WorkStatus.stopped:
        return 'Stopped';
      case WorkStatus.dayOff:
        return 'Day off';
      case WorkStatus.holiday:
        return 'Holiday';
      case WorkStatus.shortened:
        return 'Shortened';
      case WorkStatus.vacationDisplayOnly:
        return 'Vacation';
      case WorkStatus.sickDisplayOnly:
        return 'Sick leave';
    }
  }
}
