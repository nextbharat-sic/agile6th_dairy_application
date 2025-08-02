import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './expense_category_selector_widget.dart';

class AddExpenseFormWidget extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedCategory;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final List<Map<String, dynamic>> categories;
  final Function(DateTime) onDateChanged;
  final Function(String) onCategoryChanged;
  final VoidCallback onSubmit;

  const AddExpenseFormWidget({
    super.key,
    required this.selectedDate,
    required this.selectedCategory,
    required this.amountController,
    required this.descriptionController,
    required this.categories,
    required this.onDateChanged,
    required this.onCategoryChanged,
    required this.onSubmit,
  });

  @override
  AddExpenseFormWidgetState createState() => AddExpenseFormWidgetState();
}

class AddExpenseFormWidgetState extends State<AddExpenseFormWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _hasReceipt = false;

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.selectedDate,
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return DatePickerTheme(
              data: DatePickerThemeData(
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                  headerBackgroundColor:
                      AppTheme.lightTheme.colorScheme.primary,
                  headerForegroundColor:
                      AppTheme.lightTheme.colorScheme.onPrimary),
              child: child!);
        });

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateChanged(picked);
    }
  }

  void _selectCategory() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ExpenseCategorySelectorWidget(
            categories: widget.categories,
            selectedCategory: widget.selectedCategory,
            onCategorySelected: widget.onCategoryChanged));
  }

  void _attachPhoto() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Add Receipt Photo',
                  style: AppTheme.lightTheme.textTheme.titleMedium),
              SizedBox(height: 3.h),
              Row(children: [
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _hasReceipt = true);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Camera functionality coming soon')));
                        },
                        icon: CustomIconWidget(
                            iconName: 'camera_alt',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 20),
                        label: Text('Camera'))),
                SizedBox(width: 2.w),
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _hasReceipt = true);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Gallery functionality coming soon')));
                        },
                        icon: CustomIconWidget(
                            iconName: 'photo_library',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 20),
                        label: Text('Gallery'))),
              ]),
              SizedBox(height: 2.h),
            ])));
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return value;

    final number = value.replaceAll(',', '');
    if (double.tryParse(number) == null) return value;

    final formatted = double.parse(number).toStringAsFixed(0);
    return formatted.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryData = widget.categories.firstWhere(
        (cat) => cat["name"] == widget.selectedCategory,
        orElse: () => widget.categories.first);

    return Container(
        padding: EdgeInsets.only(
            left: 4.w,
            right: 4.w,
            top: 4.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 4.w),
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Expense',
                            style: AppTheme.lightTheme.textTheme.titleLarge),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: CustomIconWidget(
                                iconName: 'close',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 24)),
                      ]),

                  SizedBox(height: 3.h),

                  // Date Selection
                  InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            CustomIconWidget(
                                iconName: 'calendar_today',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 20),
                            SizedBox(width: 3.w),
                            Text(
                                '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                                style: AppTheme.lightTheme.textTheme.bodyLarge),
                            Spacer(),
                            CustomIconWidget(
                                iconName: 'arrow_drop_down',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 20),
                          ]))),

                  SizedBox(height: 2.h),

                  // Category Selection
                  InkWell(
                      onTap: _selectCategory,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            CustomIconWidget(
                                iconName:
                                    selectedCategoryData["icon"] as String,
                                color: selectedCategoryData["color"] as Color,
                                size: 20),
                            SizedBox(width: 3.w),
                            Text(widget.selectedCategory,
                                style: AppTheme.lightTheme.textTheme.bodyLarge),
                            Spacer(),
                            CustomIconWidget(
                                iconName: 'arrow_drop_down',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 20),
                          ]))),

                  SizedBox(height: 2.h),

                  // Amount Input
                  TextFormField(
                      controller: widget.amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;
                          final formatted = _formatCurrency(newValue.text);
                          return TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length));
                        }),
                      ],
                      decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '₹ ',
                          prefixStyle: AppTheme.lightTheme.textTheme.bodyLarge
                              ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600),
                          hintText: '0'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount =
                            double.tryParse(value.replaceAll(',', ''));
                        if (amount == null || amount <= 0) {
                          return 'Please enter valid amount';
                        }
                        return null;
                      }),

                  SizedBox(height: 2.h),

                  // Description Input
                  TextFormField(
                      controller: widget.descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter expense details...',
                          alignLabelWithHint: true)),

                  SizedBox(height: 2.h),

                  // Photo Attachment
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: _attachPhoto,
                            icon: CustomIconWidget(
                                iconName:
                                    _hasReceipt ? 'check_circle' : 'camera_alt',
                                color: _hasReceipt
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                                size: 20),
                            label: Text(
                                _hasReceipt ? 'Receipt Added' : 'Add Receipt'),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: _hasReceipt
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme
                                        .lightTheme.colorScheme.onSurface))),
                  ]),

                  SizedBox(height: 4.h),

                  // Submit Button
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              widget.onSubmit();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h)),
                          child: Text('Add Expense',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary)))),

                  SizedBox(height: 2.h),
                ])));
  }
}
