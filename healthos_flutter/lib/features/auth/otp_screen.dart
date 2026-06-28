import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../app/theme.dart';
import '../../core/api/auth_api.dart';
import '../../core/auth_registration.dart';
import '../../core/session.dart';
import 'widgets/otp_input_field.dart';

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
  int _resendIn = 25;
  Timer? _timer;

  String get _e164 => '+91${widget.mobile}';

  String get _displayPhone => '+91 - ${widget.mobile}';

  bool get _androidAutofill => !kIsWeb && Platform.isAndroid;

  bool get _otpComplete => _code.length == _otpLength;

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
    setState(() => _resendIn = 25);
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
    setState(() => _code = code ?? '');
    if (_code.length == _otpLength) _verify();
  }

  Future<void> _resend() async {
    if (_resendIn > 0) return;
    try {
      await ref.read(authApiProvider).initiatePhone(_e164);
      _startResendTimer();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _verify() async {
    if (_verifying || !_otpComplete) return;
    setState(() {
      _error = null;
      _verifying = true;
    });
    try {
      final api = ref.read(authApiProvider);
      final result = await api.verifyPhone(_e164, _code);

      if (result.newUser) {
        ref.read(authRegistrationProvider.notifier).setPendingRegistration(
              phone: _e164,
              registrationToken: result.registrationToken ?? '',
            );
        if (mounted) context.go('/name', extra: widget.mobile);
        return;
      }

      final token = result.accessToken;
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

  String get _timeLabel {
    final m = (_resendIn ~/ 60).toString();
    final s = (_resendIn % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthBackButton(
                  onPressed: () => context.go('/login')),
              const SizedBox(height: 24),
              Text(
                'A verification code has been sent to',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF212121),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _displayPhone,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (_androidAutofill)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Auto-reading SMS…',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                        ),
                  ),
                ),
              const SizedBox(height: 32),
              if (_androidAutofill)
                SizedBox(
                  height: 0,
                  child: Opacity(
                    opacity: 0,
                    child: PinFieldAutoFill(
                      codeLength: _otpLength,
                      currentCode: _code,
                      onCodeChanged: (c) => setState(() => _code = c ?? ''),
                    ),
                  ),
                ),
              OtpInputField(
                onChanged: (v) => setState(() => _code = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_otpComplete && !_verifying) ? _verify : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _verifying
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
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Resend OTP in ',
                      style: TextStyle(color: Color(0xFF757575), fontSize: 13)),
                  Text(
                    _timeLabel,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OtpResendChannels(
                enabled: _resendIn <= 0,
                onSms: _resend,
                onWhatsapp: _resend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
