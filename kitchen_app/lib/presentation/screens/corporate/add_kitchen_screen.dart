import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/kitchen_store.dart';
import '../../widgets/common.dart';

class AddKitchenScreen extends StatefulWidget {
  const AddKitchenScreen({super.key});

  @override
  State<AddKitchenScreen> createState() => _AddKitchenScreenState();
}

class _AddKitchenScreenState extends State<AddKitchenScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kitchen name is required')));
      return;
    }
    setState(() => _saving = true);
    final created = await context.read<KitchenStore>().addKitchen(
          name: _name.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${created.name}')),
      );
      context.go('/corporate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/corporate')),
        title: const Text('Add cloud kitchen'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Kitchen name', _name, hint: 'e.g. HealthOS - Whitefield'),
              const SizedBox(height: 16),
              _field('Address', _address, hint: 'Street, area'),
              const SizedBox(height: 16),
              _field('City', _city, hint: 'e.g. Bengaluru'),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Create kitchen',
                icon: Icons.add_business,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
