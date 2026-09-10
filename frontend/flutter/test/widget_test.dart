import 'package:flutter_test/flutter_test.dart';
import 'package:sound_accessibility_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SensoryReachApp());
    expect(find.byType(SensoryReachApp), findsOneWidget);
  });
}
