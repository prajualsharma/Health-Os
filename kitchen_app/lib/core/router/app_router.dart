import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/name_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/phone_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/corporate/add_kitchen_screen.dart';
import '../../presentation/screens/corporate/corporate_home.dart';
import '../../presentation/screens/kitchen/kitchen_shell.dart';
import '../../presentation/screens/role/role_select_screen.dart';

class AppRouter {
  AppRouter._();

  static late final GoRouter router;

  static void init(AuthProvider auth) {
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) {
        final loggedIn = auth.isAuthenticated;
        final loc = state.matchedLocation;
        final inAuth = loc.startsWith('/auth') || loc == '/';

        if (!loggedIn) {
          if (inAuth) return null;
          return '/';
        }

        // Logged in but pending registration (no token yet shouldn't happen)
        if (auth.role == null) {
          return loc == '/role' || loc == '/auth/name' ? null : '/role';
        }

        if (inAuth || loc == '/role') {
          return auth.role == SessionRole.corporate ? '/corporate' : '/kitchen';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneScreen()),
        GoRoute(
          path: '/auth/otp',
          builder: (_, state) => OtpScreen(phone: state.extra as String?),
        ),
        GoRoute(path: '/auth/name', builder: (_, __) => const NameScreen()),
        GoRoute(path: '/role', builder: (_, __) => const RoleSelectScreen()),
        GoRoute(
          path: '/corporate',
          builder: (_, __) => const CorporateHome(),
          routes: [
            GoRoute(path: 'add', builder: (_, __) => const AddKitchenScreen()),
          ],
        ),
        GoRoute(path: '/kitchen', builder: (_, __) => const KitchenShell()),
      ],
    );
  }
}
