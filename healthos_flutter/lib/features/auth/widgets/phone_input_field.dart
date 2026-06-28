import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Text(
              '+91 -',
              style: TextStyle(
                color: Color(0xFF212121),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: Color(0xFF212121),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              cursorColor: AppColors.secondary,
              onChanged: onChanged,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: '9876543210',
                hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
