import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/auth_api.dart';
import '../../core/session.dart';

final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
final _mobileRe = RegExp(r'^[6-9]\d{9}$');

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _showPassword = false;

  /// Email input switches the form into password mode inline.
  bool get _isEmail => _emailRe.hasMatch(_idController.text.trim());
  bool get _isMobile => _mobileRe.hasMatch(_idController.text.trim().replaceAll(' ', ''));

  bool _sendingOtp = false;

  Future<void> _continue() async {
    final input = _idController.text.trim().replaceAll(' ', '');
    setState(() => _error = null);

    if (_isMobile) {
      setState(() => _sendingOtp = true);
      try {
        await ref.read(authApiProvider).initiatePhone('+91$input');
        if (!mounted) return;
        context.push('/otp', extra: input);
      } on AuthException catch (e) {
        if (mounted) setState(() => _error = e.message);
      } finally {
        if (mounted) setState(() => _sendingOtp = false);
      }
      return;
    }
    if (_isEmail) {
      if (!_showPassword) {
        setState(() => _showPassword = true);
        return;
      }
      if (_passwordController.text.isEmpty) {
        setState(() => _error = 'Enter your password');
        return;
      }
      // Dummy mode: any password accepted.
      ref.read(sessionProvider.notifier).login(role: UserRole.owner, contact: input);
      context.go('/');
      return;
    }
    setState(() => _error = 'Enter a valid email or 10-digit mobile number');
  }

  void _googleLogin() {
    // Stub: real Google Sign-In to be wired with backend later.
    ref.read(sessionProvider.notifier)
        .login(role: UserRole.owner, contact: 'google-user@healthos.fit');
    context.go('/');
  }

  void _devLogin(UserRole role) {
    ref.read(sessionProvider.notifier).login(role: role, contact: devMobile);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Text('HealthOS',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Gym Management Platform',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Welcome back',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Login with email or mobile number',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _idController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          decoration: InputDecoration(
                            labelText: 'Email or mobile number',
                            prefixIcon: Icon(_isMobile
                                ? Icons.phone_android
                                : _isEmail
                                    ? Icons.alternate_email
                                    : Icons.person_outline),
                            helperText: _isMobile
                                ? 'We will send an OTP to this number'
                                : _isEmail
                                    ? 'Login with your password'
                                    : null,
                          ),
                          onChanged: (_) => setState(() {
                            if (!_isEmail) _showPassword = false;
                          }),
                          onSubmitted: (_) => _continue(),
                        ),
                        if (_showPassword && _isEmail) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            onSubmitted: (_) => _continue(),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                        ],
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_error!,
                                style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                          ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _sendingOtp ? null : _continue,
                          child: _sendingOtp
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isMobile
                                  ? 'Send OTP'
                                  : _showPassword
                                      ? 'Login'
                                      : 'Continue'),
                        ),
                        const SizedBox(height: 16),
                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or', style: Theme.of(context).textTheme.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _googleLogin,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text('Continue with Google'),
                        ),
                      ],
                    ),
                  ),
                ),
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
                const SizedBox(height: 12),
                Text('Dev mobile: $devMobile · OTP: $devOtp',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
