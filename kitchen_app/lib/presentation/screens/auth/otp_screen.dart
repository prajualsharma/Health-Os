import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/otp_input_field.dart';
import '../../widgets/common.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.phone});

  final String? phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  String _otp = '';
  int _resendIn = 25;
  Timer? _timer;

  String get _displayPhone {
    final phone = widget.phone ?? '';
    if (phone.isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return '+91 - ${digits.substring(digits.length - 10)}';
    }
    return phone;
  }

  bool get _otpComplete => _otp.length == _otpLength;

  @override
  void initState() {
    super.initState();
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

  Future<void> _resend() async {
    if (_resendIn > 0 || widget.phone == null) return;
    final auth = context.read<AuthProvider>();
    await auth.initiatePhone(widget.phone!);
    if (!mounted) return;
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_otpComplete || widget.phone == null) return;
    final auth = context.read<AuthProvider>();
    final newUser = await auth.verifyPhone(widget.phone!, _otp);
    if (!mounted) return;

    if (newUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(auth.error ?? 'Invalid code'),
        ),
      );
      return;
    }

    context.go(newUser ? '/auth/name' : '/role');
  }

  String get _timeLabel {
    final m = (_resendIn ~/ 60).toString();
    final s = (_resendIn % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
              const Text(
                'A verification code has been sent to',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _displayPhone.isEmpty ? 'your phone' : _displayPhone,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (auth.lastDevMode) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Dev mode: use code 123456',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              OtpInputField(onChanged: (v) => setState(() => _otp = v)),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Continue',
                isLoading: auth.isLoading,
                onPressed: _otpComplete ? _verify : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Resend OTP in ',
                      style: TextStyle(color: Color(0xFF757575), fontSize: 13)),
                  Text(
                    _timeLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
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
