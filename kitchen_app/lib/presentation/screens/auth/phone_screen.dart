import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_hero_scaffold.dart';
import '../../widgets/auth/phone_input_field.dart';
import '../../widgets/common.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phone = TextEditingController();
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
    final auth = context.read<AuthProvider>();
    final sent = await auth.initiatePhone(e164);
    if (!mounted) return;
    if (sent) {
      context.go('/auth/otp', extra: e164);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(auth.error ?? 'Could not send OTP'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthHeroScaffold(
      appName: 'Cloud Kitchen',
      tagline: AppConstants.tagline,
      logoIcon: Icons.restaurant_menu,
      headline: 'ORDERS IN\nREAL TIME',
      badgeText: 'LIVE KITCHEN BOARD',
      accentColor: AppColors.primary,
      sheetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Log in with your number',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          PhoneInputField(controller: _phone, onChanged: _onPhoneChanged),
          const SizedBox(height: 10),
          const Text(
            "We'll send a verification code here",
            style: TextStyle(color: Color(0xFF757575), fontSize: 12),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continue',
            isLoading: auth.isLoading,
            onPressed: _valid ? _continue : null,
          ),
          const AuthLegalFooter(),
        ],
      ),
    );
  }
}
