import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../l10n/app_localizations.dart';

class ExpenseHistoryItemWidget extends StatelessWidget {
  final Map<String, dynamic> expense;
  final List<Map<String, dynamic>> categories;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExpenseHistoryItemWidget({
    super.key,
    required this.expense,
    required this.categories,
    required this.onDelete,
    required this.onEdit,
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
    final category = categories.firstWhere(
      (cat) => cat["name"] == expense["category"],
      orElse: () => {
        "name": expense["category"],
        "icon": "more_horiz",
        "color": Colors.grey,
      },
    );

    final date = expense["date"] as DateTime;
    final amount = expense["amount"] as double;
    final description = expense["description"] as String;
    final hasReceipt = expense["hasReceipt"] as bool;

    return Dismissible(
      key: Key(expense["id"].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: AppTheme.lightTheme.colorScheme.onError,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return AlertDialog(
                  title: Text(l10n.deleteExpense),
                  content: Text(l10n.deleteConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        l10n.delete,
                        style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.error),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (direction) => onDelete(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        child: Card(
          elevation: 1,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color:
                          (category["color"] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: category["icon"] as String,
                        color: category["color"] as Color,
                        size: 20,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Expense Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getTranslatedCategoryName(expense["category"] as String, l10n),
                              style: AppTheme.lightTheme.textTheme.titleSmall,
                            ),
                            Text(
                              '₹${amount.toStringAsFixed(0).replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  )}',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          description,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            if (hasReceipt)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.2.h),
                                decoration: BoxDecoration(
                                  color: AppTheme
                                      .lightTheme.colorScheme.tertiary
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'receipt',
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      size: 12,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      'Receipt',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.tertiary,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
