import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saving_tracker/main.dart';

void main() {
  testWidgets('Saving tracker app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SavingTrackerApp());
    // Pump past the initial async storage load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Sổ Tiết Kiệm'), findsOneWidget);
  });
}
