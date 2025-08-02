import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalculationDisplayWidget extends StatelessWidget {
  final double quantity;
  final double fatPercentage;
  final double ratePerLiter;
  final double totalValue;

  const CalculationDisplayWidget({
    super.key,
    required this.quantity,
    required this.fatPercentage,
    required this.ratePerLiter,
    required this.totalValue,
  });

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(2)} L";
    } else if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(2)} K";
    } else {
      return "₹${amount.toStringAsFixed(2)}";
    }
  }

  double get _adjustedRate {
    return ratePerLiter * (fatPercentage / 3.5);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'calculate',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Calculation Summary',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildCalculationRow(
            label: 'Base Rate',
            value: '₹${ratePerLiter.toStringAsFixed(2)}/L',
            isHighlighted: false,
          ),
          SizedBox(height: 1.h),
          _buildCalculationRow(
            label: 'Fat Adjusted Rate',
            value: '₹${_adjustedRate.toStringAsFixed(2)}/L',
            isHighlighted: false,
          ),
          SizedBox(height: 1.h),
          _buildCalculationRow(
            label: 'Quantity',
            value: '${quantity.toStringAsFixed(1)} L',
            isHighlighted: false,
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 2.h),
          _buildCalculationRow(
            label: 'Total Value',
            value: _formatCurrency(totalValue),
            isHighlighted: true,
          ),
          if (quantity > 0) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Formula: Quantity × (Base Rate × Fat Factor)',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculationRow({
    required String label,
    required String value,
    required bool isHighlighted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: isHighlighted ? 1.0 : 0.7,
            ),
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Container(
          padding: isHighlighted
              ? EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h)
              : EdgeInsets.zero,
          decoration: isHighlighted
              ? BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: isHighlighted
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
              fontSize: isHighlighted ? 16.sp : null,
            ),
          ),
        ),
      ],
    );
  }
}
