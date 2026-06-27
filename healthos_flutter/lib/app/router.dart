import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session.dart';
import '../features/attendance/attendance_screens.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/gyms/gyms_screens.dart';
import '../features/members/members_screens.dart';
import '../features/memberships/membership_screens.dart';
import '../features/payments/payments_screens.dart';
import '../features/reports/reports_screens.dart';
import '../features/settings/settings_screens.dart';
import '../features/staff/staff_screens.dart';
import 'shell.dart';

int _tabOf(GoRouterState state) =>
    int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;

/// Re-evaluates router redirects when the session changes (login/logout).
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen<Session>(sessionProvider, (previous, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _SessionListenable(ref),
    redirect: (context, state) {
      final loggedIn = ref.read(sessionProvider).loggedIn;
      final onAuthPage = state.uri.path == '/login' ||
          state.uri.path == '/otp' ||
          state.uri.path == '/forgot-password';
      if (!loggedIn && !onAuthPage) return '/login';
      if (loggedIn && state.uri.path == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) =>
            OtpScreen(mobile: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/gyms', builder: (context, state) => const GymsListScreen()),
          GoRoute(path: '/gyms/add', builder: (context, state) => const AddGymScreen()),
          GoRoute(
            path: '/gyms/:id',
            builder: (context, state) =>
                GymDetailsScreen(gymId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/staff', builder: (context, state) => const StaffListScreen()),
          GoRoute(
              path: '/staff/add', builder: (context, state) => const AddStaffScreen()),
          GoRoute(
            path: '/staff/:id',
            builder: (context, state) =>
                StaffDetailsScreen(staffId: state.pathParameters['id']!),
          ),
          GoRoute(
              path: '/members',
              builder: (context, state) => const MembersListScreen()),
          GoRoute(
              path: '/members/add',
              builder: (context, state) => const AddMemberScreen()),
          GoRoute(
            path: '/members/:id',
            builder: (context, state) =>
                MemberProfileScreen(memberId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/plans',
            builder: (context, state) =>
                MembershipsScreen(initialTab: _tabOf(state)),
          ),
          GoRoute(
              path: '/plans/create',
              builder: (context, state) => const CreatePlanScreen()),
          GoRoute(
            path: '/attendance',
            builder: (context, state) =>
                AttendanceScreen(initialTab: _tabOf(state)),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => PaymentsScreen(initialTab: _tabOf(state)),
          ),
          GoRoute(
              path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(
            path: '/settings',
            builder: (context, state) => SettingsScreen(initialTab: _tabOf(state)),
          ),
        ],
      ),
    ],
  );
});
