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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Expenses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/expenses.png',
              width: 32,
              height: 32,
              color: Colors.white,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: ['Month', ..._months].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMonth = value);
                          _loadExpensesForSelectedPeriod();
                        }
                      },
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: ['Select Year', ..._years].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedYear = value);
                          _loadExpensesForSelectedPeriod();
                        }
                      },
                      underline: const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main Content Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "This Month's Expenses",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                  const SizedBox(height: 20),
                  
                  // Expense Categories
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _expensesByCategory.entries.map<Widget>((entry) {
                      return _buildExpenseChip(
                        entry.key.displayName, 
                        entry.value.toInt()
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Add Expense Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddExpenseDialog(context),
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text('ADD EXPENSE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.black, width: 1),
                        ),
                        elevation: 2,
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
            border: Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Expense',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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
                         return null;
                       }
                       
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
                              

                              final now = DateTime.now();
                              final expenseDate = DateTime(
                                year, month, day,
                                now.hour, now.minute, now.second, now.millisecond, now.microsecond
                              );
                              
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
                           backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
            ),
          ),
        ),
      ],
    );
  }

  // Update _buildExpenseChip to match the black and white theme
  Widget _buildExpenseChip(String label, int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$label: \u20b9$amount',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildExpenseListItem(ExpenseModel expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt,
              color: Colors.white,
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
