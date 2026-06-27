import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/session.dart';

void main() {
  runApp(const ProviderScope(child: HealthOsApp()));
}

class HealthOsApp extends ConsumerWidget {
  const HealthOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final dark = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'HealthOS — Gym Management',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
