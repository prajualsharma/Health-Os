import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'data/services/api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/kitchen_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthProvider();
  AppRouter.init(auth);

  ApiService.instance.onUnauthorized = () => AppRouter.router.go('/');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider(create: (_) => KitchenStore()),
      ],
      child: const KitchenApp(),
    ),
  );
}
