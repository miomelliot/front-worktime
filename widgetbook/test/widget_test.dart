import 'package:flutter_test/flutter_test.dart';
import 'package:worktime_widgetbook/main.dart';

void main() {
  testWidgets('renders widgetbook shell', (tester) async {
    await tester.pumpWidget(const WorktimeWidgetbook());
    await tester.pumpAndSettle();

    expect(find.byType(WorktimeWidgetbook), findsOneWidget);
  });
}
