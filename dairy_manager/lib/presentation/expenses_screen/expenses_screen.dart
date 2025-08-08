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

  // Add state for selected month and year at the top of _ExpensesScreenState
  String _selectedMonth = 'Month';
  String _selectedYear = 'Select Year';
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = [
    '2022', '2023', '2024'
  ];

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _expenseCategories.fold<int>(0, (sum, category) => sum + category['amount'] as int);

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
                                  if (value != null) setState(() => _selectedMonth = value);
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
                                  if (value != null) setState(() => _selectedYear = value);
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
                          Text(
                            '\u20b9${totalExpenses.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildExpenseChip('Feed', 18500),
                              _buildExpenseChip('Labour', 2500),
                              _buildExpenseChip('Healthcare', 7200),
                              _buildExpenseChip('Utilities', 3200),
                              _buildExpenseChip('Equipment', 15000),
                            ],
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
                ],
              ),
            ),
          ],
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
                  _buildExpenseField(
                    controller: feedController,
                    label: 'Feed',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  _buildExpenseField(
                    controller: labourController,
                    label: 'Labour',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  _buildExpenseField(
                    controller: healthcareController,
                    label: 'Healthcare',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  _buildExpenseField(
                    controller: utilitiesController,
                    label: 'Utilities',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  _buildExpenseField(
                    controller: equipmentController,
                    label: 'Equipment',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
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
}
