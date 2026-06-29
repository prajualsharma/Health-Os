import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/auth/auth_hero_scaffold.dart';
import '../../widgets/auth/phone_input_field.dart';
import '../../widgets/common/app_button.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
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
    if (digits.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }
    final e164 = '+91$digits';
    OnboardingStore.instance.update((d) => d.copyWith(phone: e164));

    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final sent = await auth.initiatePhone(e164);
    if (!mounted) return;
    setState(() => _loading = false);

    if (sent) {
      context.go('/auth/otp');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.red,
          content: Text(auth.error ?? 'Could not send OTP'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthHeroScaffold(
      appName: AppConstants.appName,
      tagline: AppConstants.tagline,
      logoEmoji: '🥗',
      headline: 'EAT FOR YOUR\nGOALS',
      badgeText: 'MACROS TRACKED',
      accentColor: AppColors.primary,
      heroGradient: const [
        Color(0xFF4A1F0A),
        Color(0xFF2A1005),
        Color(0xFF150802),
      ],
      sheetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Log in with your number', style: AppTypography.h2),
          const SizedBox(height: 20),
          PhoneInputField(controller: _phone, onChanged: _onPhoneChanged),
          const SizedBox(height: 10),
          Text("We'll email a verification code to your inbox",
              style: AppTypography.caption),
          const SizedBox(height: 24),
          AppButton(
            label: 'Continue',
            isLoading: _loading,
            onPressed: _valid ? _continue : null,
          ),
          const AuthLegalFooter(),
        ],
      ),
    );
  }
}
