import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../l10n/app_localizations.dart';

class ExpenseCategorySelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const ExpenseCategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  String _getTranslatedCategoryName(String categoryName, AppLocalizations l10n) {
    // Convert string category name to ExpenseCategory enum
    try {
      final category = ExpenseCategory.values.firstWhere(
        (cat) => cat.key == categoryName.toLowerCase(),
        orElse: () => ExpenseCategory.other,
      );
      
      switch (category) {
        case ExpenseCategory.feed: return l10n.feed;
        case ExpenseCategory.labour: return l10n.labour;
        case ExpenseCategory.healthcare: return l10n.healthcare;
        case ExpenseCategory.utilities: return l10n.utilities;
        case ExpenseCategory.equipment: return l10n.equipment;
        case ExpenseCategory.other: return l10n.other;
      }
    } catch (e) {
      return categoryName; // Fallback to original name if conversion fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Category',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category["name"];

              return GestureDetector(
                onTap: () {
                  onCategorySelected(category["name"] as String);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: category["icon"] as String,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : category["color"] as Color,
                        size: 24,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _getTranslatedCategoryName(category["name"] as String, l10n),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Avg: ₹${(category["averageSpending"] as double).toStringAsFixed(0)}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
