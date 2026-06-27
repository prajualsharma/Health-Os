import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../app/theme.dart';
import '../../core/api/auth_api.dart';
import '../../core/session.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String mobile;
  const OtpScreen({super.key, required this.mobile});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with CodeAutoFill {
  static const int _otpLength = 6;
  String _code = '';
  String? _error;
  bool _verifying = false;
  int _resendIn = 30;
  Timer? _timer;

  String get _e164 => '+91${widget.mobile}';

  bool get _androidAutofill => !kIsWeb && Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    if (_androidAutofill) {
      listenForCode();
    }
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendIn = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendIn <= 1) {
        t.cancel();
        setState(() => _resendIn = 0);
      } else {
        setState(() => _resendIn--);
      }
    });
  }

  @override
  void codeUpdated() {
    // Called by sms_autofill when an SMS code is auto-read on Android.
    setState(() => _code = code ?? '');
    if (_code.length == _otpLength) _verify();
  }

  Future<void> _verify() async {
    if (_verifying) return;
    setState(() {
      _error = null;
      _verifying = true;
    });
    try {
      final api = ref.read(authApiProvider);
      final result = await api.verifyPhone(_e164, _code);

      String? token = result.accessToken;
      if (result.newUser) {
        // No B2B account yet — create a minimal one so login can proceed.
        token = await api.register(
          phone: _e164,
          registrationToken: result.registrationToken ?? '',
          name: 'Gym Owner',
        );
      }

      if (token == null || token.isEmpty) {
        setState(() => _error = 'Login failed. Please try again.');
        return;
      }

      await ref
          .read(sessionProvider.notifier)
          .loginFromBackend(token: token, contact: widget.mobile);
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  void dispose() {
    if (_androidAutofill) cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.sms_outlined, size: 40, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text('Enter the 6-digit code',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Sent to +91 ${widget.mobile}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall),
                    if (_androidAutofill)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Auto-reading SMS…',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.secondary)),
                      ),
                    const SizedBox(height: 24),
                    PinFieldAutoFill(
                      codeLength: _otpLength,
                      currentCode: _code,
                      decoration: BoxLooseDecoration(
                        strokeColorBuilder:
                            const FixedColorBuilder(AppColors.primary),
                        radius: const Radius.circular(10),
                      ),
                      onCodeChanged: (code) {
                        setState(() => _code = code ?? '');
                        if ((code ?? '').length == _otpLength) _verify();
                      },
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _verifying ? null : _verify,
                      child: _verifying
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify & Login'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _resendIn == 0 ? _startResendTimer : null,
                      child: Text(_resendIn == 0
                          ? 'Resend OTP'
                          : 'Resend OTP in ${_resendIn}s'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
