import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/subscription_plan.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/app_button.dart';

class CouplePlanScreen extends StatefulWidget {
  const CouplePlanScreen({super.key});

  @override
  State<CouplePlanScreen> createState() => _CouplePlanScreenState();
}

class _CouplePlanScreenState extends State<CouplePlanScreen> {
  final _partnerPhone = TextEditingController();
  CouplePartner? _partner;
  bool _linking = false;

  @override
  void dispose() {
    _partnerPhone.dispose();
    super.dispose();
  }

  Future<void> _linkPartner() async {
    final phone = _partnerPhone.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }
    setState(() => _linking = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _partner = const CouplePartner(
        name: 'Partner',
        initials: 'Pa',
        linked: true,
      );
      _linking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<ProfileProvider>().profile;
    final myInitials = me?.initials ?? 'Me';
    final myName = me?.name ?? 'You';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: const Text('Couple Plan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primarySoft,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💑', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('One plan. Two people.', style: AppTypography.h2),
                  const SizedBox(height: 6),
                  Text(
                    'Why pay twice? Add your partner, order meals for both, '
                    'and see each other\'s progress — like Apple Health sharing.',
                    style: AppTypography.caption.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Your circle', style: AppTypography.h3),
            const SizedBox(height: 12),
            _PersonTile(name: myName, initials: myInitials, role: 'You'),
            if (_partner != null) ...[
              const SizedBox(height: 8),
              _PersonTile(
                name: _partner!.name,
                initials: _partner!.initials,
                role: 'Partner',
                linked: true,
              ),
            ],
            if (_partner == null) ...[
              const SizedBox(height: 20),
              Text('Add partner', style: AppTypography.h3),
              const SizedBox(height: 8),
              TextField(
                controller: _partnerPhone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Partner phone number',
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: _linking ? 'Linking…' : 'Invite partner',
                onPressed: _linking ? null : _linkPartner,
              ),
            ],
            const SizedBox(height: 24),
            Text('Shared features', style: AppTypography.h3),
            const SizedBox(height: 10),
            _feature(Icons.restaurant_menu, 'Order for both from one account'),
            _feature(Icons.sync, 'Synced meal delivery schedule'),
            _feature(Icons.show_chart, 'See partner\'s macros & workout progress'),
            _feature(Icons.receipt_long, 'Single bill — save on subscription'),
            const SizedBox(height: 24),
            if (_partner?.linked == true)
              AppButton(
                label: 'Start Couple Plan — ₹9,999/mo',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Couple Plan checkout coming soon'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.name,
    required this.initials,
    required this.role,
    this.linked = false,
  });

  final String name;
  final String initials;
  final String role;
  final bool linked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.bodyBold),
                Text(role, style: AppTypography.caption),
              ],
            ),
          ),
          if (linked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Linked',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
