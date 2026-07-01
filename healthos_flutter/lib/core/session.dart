import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_config.dart';
import 'api/auth_api.dart';

/// Dev credentials for prototype login.
const devMobile = '9534015459';
const devOtp = '123456';

enum UserRole { owner, manager, trainer, receptionist }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.owner => 'Gym Owner',
        UserRole.manager => 'Gym Manager',
        UserRole.trainer => 'Trainer',
        UserRole.receptionist => 'Receptionist',
      };
}

/// Maps a backend scoped role name to the app's role enum.
UserRole _roleFromScopedName(String name) => switch (name.toUpperCase()) {
      'GYM_OWNER' => UserRole.owner,
      'GYM_MANAGER' => UserRole.manager,
      'TRAINER' => UserRole.trainer,
      'RECEPTIONIST' => UserRole.receptionist,
      _ => UserRole.owner,
    };

class Session {
  final bool loggedIn;
  final UserRole role;
  final String userName;
  final String userContact;
  final String? token;

  /// Gym id the user is operating in. Owner can switch; others are pinned.
  final String activeGymId;

  const Session({
    this.loggedIn = false,
    this.role = UserRole.owner,
    this.userName = '',
    this.userContact = '',
    this.token,
    this.activeGymId = 'gym-1',
  });

  Session copyWith({
    bool? loggedIn,
    UserRole? role,
    String? userName,
    String? userContact,
    String? token,
    String? activeGymId,
  }) {
    return Session(
      loggedIn: loggedIn ?? this.loggedIn,
      role: role ?? this.role,
      userName: userName ?? this.userName,
      userContact: userContact ?? this.userContact,
      token: token ?? this.token,
      activeGymId: activeGymId ?? this.activeGymId,
    );
  }
}

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() {
    _restore();
    return const Session();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    if (token == null || token.isEmpty) return;
    try {
      await loginFromBackend(token: token, contact: '');
    } catch (_) {
      state = Session(loggedIn: true, token: token);
    }
  }

  void login({required UserRole role, required String contact, String? name}) {
    state = Session(
      loggedIn: true,
      role: role,
      userName: name ?? _defaultName(role),
      userContact: contact,
      activeGymId: 'gym-1',
    );
  }

  /// Logs in from a backend access token, resolving role/gym from memberships.
  /// Falls back to owner (with the default gym) when the user has no membership
  /// yet — gym invite / owner onboarding is a later phase.
  Future<void> loginFromBackend({
    required String token,
    required String contact,
    String? name,
  }) async {
    final memberships =
        await ref.read(authApiProvider).getMemberships(token);
    final gymMembership = memberships
        .where((m) => m.portal.toUpperCase() == 'GYM')
        .cast<Membership?>()
        .firstWhere((_) => true, orElse: () => null);

    final role = gymMembership != null
        ? _roleFromScopedName(gymMembership.role)
        : UserRole.owner;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);

    state = Session(
      loggedIn: true,
      role: role,
      userName: name ?? _defaultName(role),
      userContact: contact,
      token: token,
      activeGymId: gymMembership?.scopeId ?? 'gym-1',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    state = const Session();
  }

  void switchGym(String gymId) => state = state.copyWith(activeGymId: gymId);

  String _defaultName(UserRole role) => switch (role) {
        UserRole.owner => 'Rohan Mehta',
        UserRole.manager => 'Priya Sharma',
        UserRole.trainer => 'Vikram Singh',
        UserRole.receptionist => 'Anjali Verma',
      };
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);

class ThemeModeNotifier extends Notifier<bool> {
  static const _key = 'darkMode';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}

final darkModeProvider = NotifierProvider<ThemeModeNotifier, bool>(ThemeModeNotifier.new);
