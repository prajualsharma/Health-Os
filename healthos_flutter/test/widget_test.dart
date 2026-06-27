import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthos_flutter/main.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HealthOsApp()));
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
