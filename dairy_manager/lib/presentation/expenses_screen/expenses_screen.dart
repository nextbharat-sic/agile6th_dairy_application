import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/constants.dart';
import '../../models/expense_model.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  // State for selected month and year
  String _selectedMonth = 'Month';
  String _selectedYear = 'Select Year';
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = [
    '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025'
  ];

  @override
  void initState() {
    super.initState();
    // Set current month and year as default
    final now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _selectedYear = now.year.toString();
    
    // Load expenses for current month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  void _loadExpenses() {
    // This method will be called from the Consumer context where the provider is available
    // FIXED: Use the actual month number from the selected month name
    final monthIndex = _getMonthNumber(_selectedMonth);
    final year = int.parse(_selectedYear);
    
    print('Loading expenses for month: $_selectedMonth (number: $monthIndex), year: $year');
    
    // Get actual user ID from auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final expensesProvider = Provider.of<ExpensesProvider>(context, listen: false);
        
        if (authProvider.isAuthenticated && authProvider.userId != null) {
          print('User authenticated, loading expenses for userId: ${authProvider.userId}');
          print('Calling loadExpensesForMonth with month: $monthIndex, year: $year');
          expensesProvider.loadExpensesForMonth(authProvider.userId!, monthIndex, year);
        } else {
          print('User not authenticated or userId is null');
        }
      }
    });
  }

  /// Get the actual month number from month name
  int _getMonthNumber(String monthName) {
    switch (monthName.toLowerCase()) {
      case 'january': return 1;
      case 'february': return 2;
      case 'march': return 3;
      case 'april': return 4;
      case 'may': return 5;
      case 'june': return 6;
      case 'july': return 7;
      case 'august': return 8;
      case 'september': return 9;
      case 'october': return 10;
      case 'november': return 11;
      case 'december': return 12;
      default: return DateTime.now().month;
    }
  }

  /// Handles expense submission from the dialog
  Future<void> _handleExpenseSubmission({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController dateController,
    required TextEditingController descriptionController,
    required TextEditingController amountController,
    required ExpenseCategory selectedCategory,
    required ExpensesProvider expensesProvider,
  }) async {
    if (!formKey.currentState!.validate()) return;
    
    try {
      // Parse date
      print('Parsing date from controller: "${dateController.text}"');
      final dateParts = dateController.text.split('/');
      if (dateParts.length != 3) {
        throw Exception('Please enter date in DD/MM/YYYY format');
      }
      
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      
      print('Parsed date parts - Day: $day, Month: $month, Year: $year');
      
      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 2000 || year > 2030) {
        throw Exception('Please enter a valid date');
      }
      
      final dateTime = DateTime(year, month, day);
      print('Created DateTime object: $dateTime');
      
      if (dateTime.isAfter(DateTime.now())) {
        throw Exception('Date cannot be in the future');
      }
      
      // Parse amount - remove any non-numeric characters except decimal point
      final amountText = amountController.text.replaceAll(RegExp(r'[^\d.]'), '');
      if (amountText.isEmpty) {
        throw Exception('Please enter a valid amount');
      }
      final amount = double.parse(amountText);
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }
      
      // Get description
      final description = descriptionController.text.trim();
      if (description.isEmpty) {
        throw Exception('Please enter a description');
      }
      if (description.length < 3) {
        throw Exception('Description must be at least 3 characters long');
      }
      
      // Get actual user ID from auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated || authProvider.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to add expenses.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final success = await expensesProvider.addExpense(
        userId: authProvider.userId!,
        dateTime: dateTime,
        category: selectedCategory,
        description: description,
        amount: amount,
      );
      
      if (success) {
        Navigator.pop(context);
        
        // CRITICAL FIX: Switch to the month of the added expense so user can see it immediately
        final addedMonth = _months[dateTime.month - 1];
        final addedYear = dateTime.year.toString();
        
        // Only switch if it's different from current selection
        if (_selectedMonth != addedMonth || _selectedYear != addedYear) {
          _selectedMonth = addedMonth;
          _selectedYear = addedYear;
          print('Switched to expense month: $_selectedMonth, year: $_selectedYear');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully! Switched to ${addedMonth} ${addedYear}'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
        
        // Reload expenses for the month of the added expense
        print('Reloading expenses for expense month: $_selectedMonth, year: $_selectedYear');
        _loadExpenses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add expense. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesProvider>(
      builder: (context, expensesProvider, child) {
        final totalExpenses = expensesProvider.totalExpenses;
        final categoryTotals = expensesProvider.categoryTotals;
        final isLoading = expensesProvider.isLoading;
        final error = expensesProvider.error;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.whiteColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: AppTheme.whiteColor),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Blue top background with rounded bottom edges
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: const Color(0xFF517186),
                  ),
                ),
                // Lower background with rounded top container
                Positioned(
                  top: 180,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: Container(
                      color: const Color(0xFFDEE4E8),
                    ),
                  ),
                ),
                // Main content
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Expenses logo in a white circle with shadow
                      Material(
                        elevation: 6,
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: Container(
                          width: 120,
                          height: 120,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/expenses.png',
                                height: 54,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  color: Color(0xFF517186),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E5E6),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Month and Year dropdowns
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Month',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        DropdownButton<String>(
                                          value: _selectedMonth,
                                          isExpanded: true,
                                          items: _months.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() => _selectedMonth = value);
                                              _loadExpenses();
                                            }
                                          },
                                          underline: SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Year',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        DropdownButton<String>(
                                          value: _selectedYear,
                                          isExpanded: true,
                                          items: _years.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() => _selectedYear = value);
                                              _loadExpenses();
                                            }
                                          },
                                          underline: SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Quick Navigation to Months with Expenses
                              Consumer<ExpensesProvider>(
                                builder: (context, expensesProvider, child) {
                                  if (expensesProvider.isLoading) return const SizedBox.shrink();
                                  
                                  // Get unique months with expenses
                                  final monthsWithExpenses = <String>{};
                                  for (final expense in expensesProvider.expenses) {
                                    final monthName = _months[expense.dateTime.month - 1];
                                    final year = expense.dateTime.year.toString();
                                    monthsWithExpenses.add('$monthName $year');
                                  }
                                  
                                  if (monthsWithExpenses.isEmpty) return const SizedBox.shrink();
                                  
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Months with expenses:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: monthsWithExpenses.map((monthYear) {
                                          final isCurrent = monthYear == '${_selectedMonth} ${_selectedYear}';
                                          return GestureDetector(
                                            onTap: () {
                                              final parts = monthYear.split(' ');
                                              if (parts.length == 2) {
                                                setState(() {
                                                  _selectedMonth = parts[0];
                                                  _selectedYear = parts[1];
                                                });
                                                _loadExpenses();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: isCurrent ? AppTheme.accentColor : Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: isCurrent ? Colors.grey.shade300 : Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                monthYear,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isCurrent ? Colors.white : Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "This Month's Expenses",
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${expensesProvider.expenses.length} total entries',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _loadExpenses(),
                                    icon: Icon(Icons.refresh, color: AppTheme.textSecondaryColor),
                                    tooltip: 'Refresh expenses',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\u20b9${totalExpenses.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Dynamic content based on state
                              if (isLoading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                )
                              else if (error != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    'Error: $error',
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                )
                                                            else if (categoryTotals.isEmpty)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No expenses for ${_selectedMonth} ${_selectedYear}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add your first expense for this month!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                // Show only category totals (summed expenses)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: categoryTotals.entries.map((entry) {
                                    // Count expenses in this category
                                    final entryCount = expensesProvider.expenses
                                        .where((expense) => expense.category == entry.key)
                                        .length;
                                    
                                    return _buildExpenseChip(
                                      entry.key.displayName, 
                                      entry.value.toInt(),
                                      entryCount
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddExpenseDialog(context, expensesProvider),
                                  icon: const Icon(Icons.add, color: Colors.black),
                                  label: const Text('Add Expense', style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.black12),
                                    ),
                                    elevation: 4,
                                    shadowColor: Colors.black12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context, ExpensesProvider expensesProvider) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    ExpenseCategory selectedCategory = ExpenseCategory.feed;
    
    // Set current date as default, but allow user to change it
    final now = DateTime.now();
    dateController.text = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    
    print('Initial date set to: ${dateController.text}');
    

    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Expense',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildExpenseField(
                    controller: dateController,
                    label: 'Date',
                    placeholder: 'dd/mm/yyyy',
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2017),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: AppTheme.primaryColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category dropdown
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Category',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<ExpenseCategory>(
                          value: selectedCategory,
                          items: ExpenseCategory.values.map((category) {
                            return DropdownMenuItem<ExpenseCategory>(
                              value: category,
                              child: Text(category.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              selectedCategory = value;
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpenseField(
                    controller: descriptionController,
                    label: 'Description',
                    placeholder: 'Enter expense description',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildExpenseField(
                    controller: amountController,
                    label: 'Amount',
                    placeholder: '0.00',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final amount = double.tryParse(value.replaceAll('/', ''));
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () => _handleExpenseSubmission(
                          context: context,
                          formKey: formKey,
                          dateController: dateController,
                          descriptionController: descriptionController,
                          amountController: amountController,
                          selectedCategory: selectedCategory,
                          expensesProvider: expensesProvider,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cardColor,
                          foregroundColor: AppTheme.textPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildExpenseField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        // Label
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Vertical line
        Container(
          width: 2,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        
        // Input field
        Expanded(
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor: AppTheme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.secondaryColor,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseChip(String label, int amount, int entryCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: \u20b9$amount',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (entryCount > 1)
            Text(
              '($entryCount entries)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }


}
