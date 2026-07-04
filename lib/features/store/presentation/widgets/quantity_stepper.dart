import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Compact −/value/+ stepper used in the cart and product details.
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.max = 99,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, enabled && quantity > 1,
              () => onChanged(quantity - 1)),
          Container(
            constraints: const BoxConstraints(minWidth: 34),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _btn(Icons.add, enabled && quantity < max,
              () => onChanged(quantity + 1)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: active ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: active ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}
