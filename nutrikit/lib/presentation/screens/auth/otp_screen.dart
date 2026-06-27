import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';

const int _otpLength = 6;

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(_otpLength, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 42;
  bool _loading = false;

  String get _phone => OnboardingStore.instance.data.phone;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _seconds = 42);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    await auth.initiatePhone(_phone);
    if (!mounted) return;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
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
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final devMode = context.watch<AuthProvider>().lastDevMode;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VERIFY PHONE',
                  style: AppTypography.label.copyWith(color: AppColors.green)),
              const SizedBox(height: 6),
              Text('Enter OTP', style: AppTypography.h1),
              const SizedBox(height: 4),
              Text('Sent on WhatsApp to ${_phone.isEmpty ? 'your phone' : _phone}',
                  style: AppTypography.caption),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) => _otpBox(i)),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  const Text('Resend in ',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  if (_seconds > 0)
                    Text(_timeLabel,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ))
                  else
                    GestureDetector(
                      onTap: _resend,
                      child: const Text('Resend code',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                ],
              ),
              const SizedBox(height: 36),
              AppButton(
                label: 'Verify & Continue',
                isLoading: _loading,
                onPressed: _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int i) {
    final filled = _controllers[i].text.isNotEmpty;
    final active = _nodes[i].hasFocus || filled;
    return SizedBox(
      width: 46,
      height: 60,
      child: TextField(
        controller: _controllers[i],
        focusNode: _nodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w900,
          fontSize: 24,
        ),
        cursorColor: AppColors.green,
        onChanged: (v) {
          if (v.isNotEmpty && i < _otpLength - 1) {
            _nodes[i + 1].requestFocus();
          } else if (v.isEmpty && i > 0) {
            _nodes[i - 1].requestFocus();
          }
          setState(() {});
        },
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: active ? AppColors.green : AppColors.cardBorder,
              width: active ? 1.5 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5),
          ),
        ),
      ),
    );
  }
}
