import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/auth/otp_input_field.dart';
import '../../widgets/common/app_button.dart';

const int _otpLength = 6;

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  Timer? _timer;
  int _seconds = 25;
  bool _loading = false;
  String _otp = '';

  String get _phone => OnboardingStore.instance.data.phone;

  String get _displayPhone {
    if (_phone.isEmpty) return '';
    final digits = _phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return '+91 - ${digits.substring(digits.length - 10)}';
    }
    return _phone;
  }

  bool get _otpComplete => _otp.length == _otpLength;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _seconds = 25);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _resend() async {
    if (_seconds > 0) return;
    final auth = context.read<AuthProvider>();
    await auth.initiatePhone(_phone);
    if (!mounted) return;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_otpComplete) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final newUser = await auth.verifyPhone(_phone, _otp);
    if (!mounted) return;
    setState(() => _loading = false);

    if (newUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.red,
          content: Text(auth.error ?? 'Verification failed'),
        ),
      );
      return;
    }
    context.go(newUser ? '/onboarding/name' : '/home/dashboard');
  }

  String get _timeLabel {
    final m = (_seconds ~/ 60).toString();
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final devMode = context.watch<AuthProvider>().lastDevMode;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthBackButton(onPressed: () => context.go('/auth/phone')),
              const SizedBox(height: 24),
              Text(
                'A verification code has been sent to',
                style: AppTypography.h2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                _displayPhone.isEmpty ? 'your phone' : _displayPhone,
                style: AppTypography.bodyBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
              if (devMode) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dev mode: check the server logs for your code (default 123456).',
                    style: AppTypography.caption,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              OtpInputField(onChanged: (v) => setState(() => _otp = v)),
              const SizedBox(height: 24),
              AppButton(
                label: 'Continue',
                isLoading: _loading,
                onPressed: _otpComplete ? _verify : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Resend OTP in ',
                      style: AppTypography.caption.copyWith(fontSize: 13)),
                  Text(
                    _timeLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OtpResendChannels(
                enabled: _seconds <= 0,
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
