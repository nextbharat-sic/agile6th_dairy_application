import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../backend/services/expense_service.dart';
import '../../backend/repositories/expense_repository.dart';
import '../../constants/constants.dart';
import '../../models/expense_model.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late ExpenseService _expenseService;
  String? _userId;
  bool _isLoading = true;
  
  // Real data from backend
  List<ExpenseModel> _expenses = [];
  Map<ExpenseCategory, double> _expensesByCategory = {};
  double _totalExpenses = 0.0;
  
  // UI state
  String _selectedMonth = 'Month';
  String _selectedYear = 'Select Year';
  
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = [
    '2020', '2021', '2022', '2023', '2024', '2025'
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadExpenses();
  }

  void _initializeServices() {
    final firestore = FirebaseFirestore.instance;
    final expenseRepo = ExpenseRepository(firestore);
    _expenseService = ExpenseService(expenseRepo: expenseRepo);
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadExpenses() async {
    if (_userId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final currentDate = DateTime.now();
      final expenses = await _expenseService.getExpensesForMonth(
        _userId!, 
        currentDate.month, 
        currentDate.year
      );
      
      final totalExpenses = await _expenseService.getTotalExpensesForMonth(
        _userId!, 
        currentDate.month, 
        currentDate.year
      );
      
      final expensesByCategory = await _expenseService.getExpensesByCategoryForMonth(
        _userId!, 
        currentDate.month, 
        currentDate.year
      );
      
      setState(() {
        _expenses = expenses;
        _totalExpenses = totalExpenses;
        _expensesByCategory = expensesByCategory;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading expenses: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExpensesForSelectedPeriod() async {
    if (_userId == null || _selectedMonth == 'Month' || _selectedYear == 'Select Year') return;
    
    setState(() => _isLoading = true);
    
    try {
      final monthIndex = _months.indexOf(_selectedMonth) + 1;
      final year = int.parse(_selectedYear);
      
      final expenses = await _expenseService.getExpensesForMonth(
        _userId!, 
        monthIndex, 
        year
      );
      
      final totalExpenses = await _expenseService.getTotalExpensesForMonth(
        _userId!, 
        monthIndex, 
        year
      );
      
      final expensesByCategory = await _expenseService.getExpensesByCategoryForMonth(
        _userId!, 
        monthIndex, 
        year
      );
      
      setState(() {
        _expenses = expenses;
        _totalExpenses = totalExpenses;
        _expensesByCategory = expensesByCategory;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading expenses for selected period: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

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
                bottomLeft: Radius.circular(40), // Increased from 32
                bottomRight: Radius.circular(40), // Increased from 32
              ),
              child: Container(
                height: 220,
                width: double.infinity,
                color: const Color(0xFF517186), // #517186
              ),
            ),
            // Replace the lower background with a rounded top container that fills the lower half
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
                  color: const Color(0xFFDEE4E8), // #DEE4E8
                ),
              ),
            ),
            // Main content
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SizedBox(height: 40), // Reduced from 60 to move logo up by 20px
                  // Expenses logo in a white circle with shadow, with 'Expenses' text inside
                  Material(
                    elevation: 6,
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: Container(
                      width: 120, // Increased from 90
                      height: 120, // Increased from 90
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
                            height: 54, // Increased from 32
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8), // Increased spacing
                          Text(
                            'Expenses',
                            style: TextStyle(
                              color: Color(0xFF517186),
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Increased from 14
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // After the logo, increase the spacing before the expenses section
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E5E6), // #E4E5E6
                        borderRadius: BorderRadius.circular(40), // Match background section
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value: _selectedMonth,
                                items: ['Month', ..._months].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedMonth = value);
                                    _loadExpensesForSelectedPeriod();
                                  }
                                },
                                underline: SizedBox(),
                              ),
                              DropdownButton<String>(
                                value: _selectedYear,
                                items: ['Select Year', ..._years].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedYear = value);
                                    _loadExpensesForSelectedPeriod();
                                  }
                                },
                                underline: SizedBox(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "This Month's Expenses",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isLoading 
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              )
                            : Text(
                                '\u20b9${_totalExpenses.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _expensesByCategory.entries.map((entry) {
                              return _buildExpenseChip(
                                entry.key.displayName, 
                                entry.value.toInt()
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddExpenseDialog(context),
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
                  
                  // Recent Expenses Section
                  const SizedBox(height: 24),
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
                          Text(
                            'Recent Expenses',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : _expenses.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No expenses found for this period',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _expenses.take(5).map((expense) => _buildExpenseListItem(expense)).toList(),
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
  }



  void _showAddExpenseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    ExpenseCategory selectedCategory = ExpenseCategory.feed;
    
    dateController.text = '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue, width: 2, style: BorderStyle.solid),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Expense popup',
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
                        firstDate: DateTime(2020),
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
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<ExpenseCategory>(
                          value: selectedCategory,
                          decoration: InputDecoration(
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Utilities field
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
                  
                  // Equipment field
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
                  const SizedBox(height: 24),
                  
                  // Submit button
                  Center(
                    child: SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              // Parse date
                              final dateParts = dateController.text.split('/');
                              final day = int.parse(dateParts[0]);
                              final month = int.parse(dateParts[1]);
                              final year = int.parse(dateParts[2]);
                              final expenseDate = DateTime(year, month, day);
                              
                              // Parse amount
                              final amount = double.parse(amountController.text.replaceAll('/', ''));
                              
                              // Add expense to backend
                              await _expenseService.addExpense(
                                userId: _userId!,
                                dateTime: expenseDate,
                                category: selectedCategory,
                                description: descriptionController.text.trim(),
                                amount: amount,
                              );
                              
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense added successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              // Reload expenses
                              _loadExpenses();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding expense: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
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
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Update _buildExpenseChip to look like a white button
  Widget _buildExpenseChip(String label, int amount) {
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
      child: Text(
        '$label: \u20b9$amount',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

fl  Widget _buildExpenseListItem(ExpenseModel expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense.dateTime.day}/${expense.dateTime.month}/${expense.dateTime.year} • ${expense.category.displayName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${expense.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


}
