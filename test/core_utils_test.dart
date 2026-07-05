import 'package:flutter_test/flutter_test.dart';
import 'package:worktime/core/utils/date_formats.dart';
import 'package:worktime/core/utils/duration_formats.dart';

void main() {
  group('ApiDuration', () {
    test('formats seconds as hms and compact hm', () {
      expect(ApiDuration.formatHms(3661), '1:01:01');
      expect(ApiDuration.formatHm(30600), '8h 30m');
      expect(ApiDuration.formatHm(2700), '45m');
    });

    test('converts Go duration nanoseconds', () {
      expect(ApiDuration.nanosToSeconds(9000000000), 9);
      expect(ApiDuration.secondsToNanos(9), 9000000000);
      expect(ApiDuration.formatTimeOfDayFromNanos(32400000000000), '09:00');
    });
  });

  group('ApiDate', () {
    test('formats and parses logical dates', () {
      final date = DateTime(2026, 7, 5, 18, 30);
      expect(ApiDate.formatDateOnly(date), '2026-07-05');
      expect(ApiDate.parseLogicalDate('2026-07-05')?.day, 5);
      expect(ApiDate.parseLogicalDate('2026-07-05T00:00:00Z')?.month, 7);
    });
  });
}
