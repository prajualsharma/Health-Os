import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/auth_api.dart';
import '../../core/auth_registration.dart';
import '../../core/session.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key, this.mobile});

  final String? mobile;

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _name = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    final reg = ref.read(authRegistrationProvider);
    final phone = reg.phone ?? '+91${widget.mobile ?? ''}';
    final token = reg.registrationToken ?? '';

    if (phone.isEmpty || token.isEmpty) {
      setState(() => _error = 'Session expired. Please log in again.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final accessToken = await ref.read(authApiProvider).register(
            phone: phone,
            registrationToken: token,
            name: name,
          );

      if (accessToken.isEmpty) {
        setState(() => _error = 'Registration failed. Please try again.');
        return;
      }

      ref.read(authRegistrationProvider.notifier).clear();
      final contact = widget.mobile ?? phone.replaceAll(RegExp(r'\D'), '').substring(2);
      await ref.read(sessionProvider.notifier).loginFromBackend(
            token: accessToken,
            contact: contact,
            name: name,
          );
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF212121)),
          onPressed: () => context.go('/otp', extra: widget.mobile),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's your name?",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'So we can personalise your gym dashboard',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF757575),
                    ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Your full name',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _continue(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _continue,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
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
            ],
          ),
        ),
      ),
    );
  }
}
