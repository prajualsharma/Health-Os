import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutrikit/app.dart';
import 'package:nutrikit/presentation/providers/auth_provider.dart';
import 'package:nutrikit/presentation/providers/profile_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: const NutriKitApp(),
      ),
    );

    // Let the async root redirect resolve and the splash build (avoid
    // pumpAndSettle since the splash runs looping animations).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NutriKit'), findsOneWidget);

    // Advance past the 1.8s splash timer so it navigates and disposes,
    // leaving no pending timers when the test ends.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
