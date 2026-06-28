import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds phone-auth state between OTP verify and name registration.
class AuthRegistrationState {
  const AuthRegistrationState({
    this.phone,
    this.registrationToken,
  });

  final String? phone;
  final String? registrationToken;

  AuthRegistrationState copyWith({
    String? phone,
    String? registrationToken,
  }) =>
      AuthRegistrationState(
        phone: phone ?? this.phone,
        registrationToken: registrationToken ?? this.registrationToken,
      );
}

class AuthRegistrationNotifier extends Notifier<AuthRegistrationState> {
  @override
  AuthRegistrationState build() => const AuthRegistrationState();

  void setPendingRegistration({
    required String phone,
    required String registrationToken,
  }) {
    state = AuthRegistrationState(
      phone: phone,
      registrationToken: registrationToken,
    );
  }

  void clear() => state = const AuthRegistrationState();
}

final authRegistrationProvider =
    NotifierProvider<AuthRegistrationNotifier, AuthRegistrationState>(
        AuthRegistrationNotifier.new);
