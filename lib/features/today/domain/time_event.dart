class TimeEvent {
  const TimeEvent({
    required this.action,
    required this.time,
    required this.note,
  });

  final String action;
  final DateTime time;
  final String note;

  /// Parses a `GET /time-tracking/events` entry. `event_type` uses the
  /// backend's own vocabulary (`work_started`, `work_paused`, ...) — mapped
  /// to the short `action` strings the UI already switches on.
  factory TimeEvent.fromJson(Map<String, dynamic> json) {
    final eventType = json['event_type'] as String;
    return TimeEvent(
      action: _actionFromEventType(eventType),
      time: DateTime.parse(json['event_time'] as String),
      note: '',
    );
  }
}

String _actionFromEventType(String eventType) {
  switch (eventType) {
    case 'work_started':
      return 'start';
    case 'work_paused':
      return 'pause';
    case 'work_resumed':
      return 'resume';
    case 'work_stopped':
      return 'stop';
    default:
      return eventType;
  }
}
