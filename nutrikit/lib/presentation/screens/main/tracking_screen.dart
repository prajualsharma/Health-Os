import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/order.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/common/app_card.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const String _orderId = '#NK-20240531-1847';
  Timer? _poll;
  OrderStatus? _status;

  @override
  void initState() {
    super.initState();
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _fetch());
  }

  Future<void> _fetch() async {
    try {
      final status = await ApiService.instance.getOrderStatus(_orderId);
      if (!mounted) return;
      setState(() => _status = status);
    } catch (_) {
      // Keep last known status on poll failure.
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _status?.steps ?? const [];
    final eta = _status?.etaMinutes ?? 35;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Track Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('Estimated Arrival', style: AppTypography.caption),
                      const SizedBox(height: 4),
                      Text(
                        '~$eta min',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(_orderId, style: AppTypography.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < steps.length; i++)
                        _stepRow(steps[i], i == steps.length - 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepRow(TrackingStep step, bool isLast) {
    final done = step.state == 'done';
    final active = step.state == 'active';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.greenGlow
                      : (done ? AppColors.green : AppColors.surface),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done || active
                        ? AppColors.green
                        : AppColors.cardBorder,
                    width: 1.5,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : active
                        ? const Center(
                            child: CircleAvatar(
                              radius: 4,
                              backgroundColor: AppColors.green,
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? AppColors.green : AppColors.cardBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    color: done || active ? AppColors.text : AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (step.time.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(step.time, style: AppTypography.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
