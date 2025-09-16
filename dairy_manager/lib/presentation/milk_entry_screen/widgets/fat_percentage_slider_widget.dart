import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FatPercentageSliderWidget extends StatelessWidget {
  final double fatPercentage;
  final Function(double) onFatPercentageChanged;

  const FatPercentageSliderWidget({
    super.key,
    required this.fatPercentage,
    required this.onFatPercentageChanged,
  });

  Color _getFatQualityColor(double fatPercentage) {
    if (fatPercentage < 3.0) {
      return Colors.orange;
    } else if (fatPercentage < 4.0) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (fatPercentage < 6.0) {
      return Colors.green;
    } else {
      return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getFatQualityLabel(double fatPercentage) {
    if (fatPercentage < 3.0) {
      return 'Low Fat';
    } else if (fatPercentage < 4.0) {
      return 'Standard';
    } else if (fatPercentage < 6.0) {
      return 'High Quality';
    } else {
      return 'Premium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fat Percentage',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color:
                    _getFatQualityColor(fatPercentage).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _getFatQualityColor(fatPercentage).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getFatQualityLabel(fatPercentage),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _getFatQualityColor(fatPercentage),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1.0%',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${fatPercentage.toStringAsFixed(1)}%',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '8.0%',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getFatQualityColor(fatPercentage),
                  inactiveTrackColor:
                      _getFatQualityColor(fatPercentage).withValues(alpha: 0.2),
                  thumbColor: _getFatQualityColor(fatPercentage),
                  overlayColor:
                      _getFatQualityColor(fatPercentage).withValues(alpha: 0.2),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: fatPercentage,
                  min: 1.0,
                  max: 8.0,
                  divisions: 70,
                  onChanged: onFatPercentageChanged,
                ),
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
            Expanded(
              child: Text(
                'Fat percentage affects the rate calculation',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
