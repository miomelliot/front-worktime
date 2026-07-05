import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worktime/app/app.dart';

void main() {
  testWidgets('renders the fake login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WorktimeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Worktime'), findsOneWidget);
    expect(find.text('Login as Employee'), findsOneWidget);
    expect(find.text('Login as Manager'), findsOneWidget);
    expect(find.text('Login as Admin'), findsOneWidget);
  });
}
