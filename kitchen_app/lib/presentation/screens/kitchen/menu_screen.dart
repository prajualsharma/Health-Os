import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../providers/kitchen_store.dart';
import '../../widgets/common.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final menu = store.menu;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: store.loadingBoard && menu.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : menu.isEmpty
              ? const EmptyHint(
                  icon: Icons.restaurant_menu, message: 'No menu items yet')
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    for (final category in MealCategory.values)
                      ..._categorySection(context, store, category),
                  ],
                ),
    );
  }

  List<Widget> _categorySection(
      BuildContext context, KitchenStore store, MealCategory category) {
    final items = store.menu.where((m) => m.category == category).toList();
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Row(
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(category.label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      ...items.map((item) => _MenuTile(item: item)),
      const SizedBox(height: 8),
    ];
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddMenuItemSheet(),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final store = context.read<KitchenStore>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          VegDot(veg: item.veg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (item.description != null)
                  Text(item.description!,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text('₹${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: item.available,
                activeThumbColor: AppColors.success,
                onChanged: (_) => store.toggleAvailability(item),
              ),
              Text(item.available ? 'Available' : 'Sold out',
                  style: TextStyle(
                      fontSize: 11,
                      color: item.available ? AppColors.success : AppColors.dim)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddMenuItemSheet extends StatefulWidget {
  const _AddMenuItemSheet();

  @override
  State<_AddMenuItemSheet> createState() => _AddMenuItemSheetState();
}

class _AddMenuItemSheetState extends State<_AddMenuItemSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  MealCategory _category = MealCategory.lunch;
  bool _veg = true;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = int.tryParse(_price.text.trim()) ?? 0;
    if (_name.text.trim().isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name and a valid price')),
      );
      return;
    }
    await context.read<KitchenStore>().addMenuItem(
          name: _name.text.trim(),
          category: _category,
          priceCents: price * 100,
          veg: _veg,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add menu item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Item name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                hintText: 'Price (₹)', prefixText: '₹ '),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MealCategory>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            dropdownColor: AppColors.surface,
            items: MealCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Veg'),
              Switch(
                value: _veg,
                activeThumbColor: AppColors.veg,
                onChanged: (v) => setState(() => _veg = v),
              ),
              Text(_veg ? 'Vegetarian' : 'Non-veg',
                  style: const TextStyle(color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Add to menu', onPressed: _save),
        ],
      ),
    );
  }
}
