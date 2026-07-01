import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/name_utils.dart';
import '../../../core/utils/validators.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_field.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final formatted = toTitleCaseName(_name.text.trim());
    OnboardingStore.instance.update((d) => d.copyWith(name: formatted));
    context.push(OnboardingFlow.nextPath('/onboarding/name')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/name',
      title: "What's your name?",
      subtitle: 'We will use this to personalize your plan.',
      nextEnabled: _name.text.trim().isNotEmpty,
      onNext: _continue,
      body: Form(
        key: _formKey,
        child: OnboardingTextField(
          controller: _name,
          hintText: 'Your full name',
          onChanged: (_) => setState(() {}),
          validator: (v) => Validators.required(v, 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
      ),
    );
  }
}
