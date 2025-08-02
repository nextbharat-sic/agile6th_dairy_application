import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'amount': 12000, 'color': AppTheme.primaryColor},
    {'name': 'Labour', 'amount': 8000, 'color': AppTheme.accentColor},
    {'name': 'Medicine', 'amount': 6000, 'color': AppTheme.warningColor},
    {'name': 'Other', 'amount': 4400, 'color': AppTheme.secondaryColor},
  ];

  final List<Map<String, dynamic>> _recentExpenses = [
    {
      'date': '2024-01-20',
      'item': 'Cattle Feed',
      'amount': 2500,
      'category': 'Food',
    },
    {
      'date': '2024-01-19',
      'item': 'Worker Salary',
      'amount': 2000,
      'category': 'Labour',
    },
    {
      'date': '2024-01-18',
      'item': 'Vaccination',
      'amount': 1500,
      'category': 'Medicine',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _expenseCategories.fold<int>(0, (sum, category) => sum + category['amount'] as int);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Expenses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.whiteColor,
            fontWeight: FontWeight.w600,
          ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Expenses Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                  ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Monthly Expenses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalExpenses.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Expense Categories
                        Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.whiteColor,
                  fontWeight: FontWeight.w600,
                        ),
              ),
              
              const SizedBox(height: 16),
              
              ..._expenseCategories.map((category) => _buildCategoryCard(category)),
              
              const SizedBox(height: 32),
              
              // Add Expense Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddExpenseDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Recent Expenses
                    Text(
                      'Recent Expenses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.whiteColor,
                  fontWeight: FontWeight.w600,
                    ),
                      ),
              
              const SizedBox(height: 16),
              
              ..._recentExpenses.map((expense) => _buildExpenseItem(expense)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final percentage = (category['amount'] as int) / _expenseCategories.fold<int>(0, (sum, cat) => sum + cat['amount'] as int);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: category['color'] as Color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
                        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: AppTheme.textSecondaryColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(category['color'] as Color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${category['amount']}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
                          children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt,
              color: AppTheme.primaryColor,
              size: 20,
            ),
                            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                            Text(
                  expense['item'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                              ),
                            ),
                const SizedBox(height: 4),
                Text(
                  '${expense['date']} • ${expense['category']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                            ),
                          ],
                        ),
                      ),
          Text(
            '₹${expense['amount']}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController();
    final feedController = TextEditingController();
    final labourController = TextEditingController();
    final healthcareController = TextEditingController();
    final utilitiesController = TextEditingController();
    final equipmentController = TextEditingController();
    
    dateController.text = DateTime.now().toString().split(' ')[0];

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
                  // Title
                  Text(
                    'Expense popup',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Form Fields
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
                  
                  _buildExpenseField(
                    controller: feedController,
                    label: 'Feed',
                    placeholder: 'Input Text',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildExpenseField(
                    controller: labourController,
                    label: 'Labour',
                    placeholder: 'Input Text',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildExpenseField(
                    controller: healthcareController,
                    label: 'Healthcare',
                    placeholder: 'Input Text',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildExpenseField(
                    controller: utilitiesController,
                    label: 'Utilities',
                    placeholder: 'Input Text',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildExpenseField(
                    controller: equipmentController,
                    label: 'Equipment',
                    placeholder: 'Input Text',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  Center(
                    child: SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // Handle form submission
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Expense added successfully!'),
                                backgroundColor: AppTheme.accentColor,
                              ),
                            );
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
}
