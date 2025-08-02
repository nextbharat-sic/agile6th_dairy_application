import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuantityInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final double quantity;
  final Function(double) onQuantityChanged;

  const QuantityInputWidget({
    super.key,
    required this.controller,
    required this.quantity,
    required this.onQuantityChanged,
  });

  void _incrementQuantity() {
    final newQuantity = quantity + 0.5;
    if (newQuantity <= 100.0) {
      onQuantityChanged(newQuantity);
    }
  }

  void _decrementQuantity() {
    final newQuantity = quantity - 0.5;
    if (newQuantity >= 0.0) {
      onQuantityChanged(newQuantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity (Liters)',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 6.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              _buildStepperButton(
                icon: 'remove',
                onPressed: quantity > 0 ? _decrementQuantity : null,
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.0',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,1}')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  onChanged: (value) {
                    final parsedValue = double.tryParse(value) ?? 0.0;
                    if (parsedValue <= 100.0) {
                      onQuantityChanged(parsedValue);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    final parsedValue = double.tryParse(value);
                    if (parsedValue == null || parsedValue <= 0) {
                      return 'Please enter valid quantity';
                    }
                    if (parsedValue > 100) {
                      return 'Quantity cannot exceed 100 liters';
                    }
                    return null;
                  },
                ),
              ),
              _buildStepperButton(
                icon: 'add',
                onPressed: quantity < 100 ? _incrementQuantity : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'info_outline',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              'Use +/- buttons for quick adjustment',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required String icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 12.w,
      height: 6.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: onPressed != null
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: onPressed != null
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.3),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
