import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/auth_api.dart';
import '../../core/session.dart';
import 'widgets/auth_hero_scaffold.dart';
import 'widgets/phone_input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  String? _error;
  bool _sendingOtp = false;
  bool _valid = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    setState(() => _valid = digits.length == 10);
  }

  Future<void> _continue() async {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    setState(() => _error = null);

    if (digits.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number');
      return;
    }

    setState(() => _sendingOtp = true);
    try {
      await ref.read(authApiProvider).initiatePhone('+91$digits');
      if (!mounted) return;
      context.push('/otp', extra: digits);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  void _devLogin(UserRole role) {
    ref.read(sessionProvider.notifier).login(role: role, contact: devMobile);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AuthHeroScaffold(
      appName: 'HealthOS',
      tagline: 'Gym Management Platform',
      logoIcon: Icons.fitness_center,
      headline: 'RUN YOUR GYM\nSMARTER',
      badgeText: 'ALL IN ONE PLACE',
      accentColor: AppColors.secondary,
      sheetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Log in with your number',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF212121),
                ),
          ),
          const SizedBox(height: 20),
          PhoneInputField(controller: _phone, onChanged: _onPhoneChanged),
          const SizedBox(height: 10),
          Text(
            "We'll send a verification code here",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF757575),
                ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_valid && !_sendingOtp) ? _continue : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: const Color(0xFFBDBDBD),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _sendingOtp
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continue',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const AuthLegalFooter(),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            Text('Dev preview — login as:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final role in UserRole.values)
                  ActionChip(
                    label: Text(role.label),
                    onPressed: () => _devLogin(role),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
