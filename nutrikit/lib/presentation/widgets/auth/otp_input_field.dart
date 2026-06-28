import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Single full-width OTP field with dot placeholders (Swish-style).
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    required this.onChanged,
    this.length = 6,
  });

  final ValueChanged<String> onChanged;
  final int length;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (i) {
                final filled = i < _controller.text.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: filled ? AppColors.text : AppColors.dim,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                widget.onChanged(v);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular back button for OTP screen.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF0F0F0),
          shape: const CircleBorder(),
        ),
        icon: const Icon(Icons.chevron_left, color: AppColors.text, size: 28),
      ),
    );
  }
}

/// SMS / WhatsApp resend chips.
class OtpResendChannels extends StatelessWidget {
  const OtpResendChannels({
    super.key,
    required this.onSms,
    required this.onWhatsapp,
    this.enabled = true,
  });

  final VoidCallback onSms;
  final VoidCallback onWhatsapp;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ChannelChip(
            icon: Icons.sms_outlined,
            label: 'SMS',
            onTap: enabled ? onSms : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ChannelChip(
            icon: Icons.chat_bubble_outline,
            label: 'Whatsapp',
            onTap: enabled ? onWhatsapp : null,
          ),
        ),
      ],
    );
  }
}

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap != null ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
