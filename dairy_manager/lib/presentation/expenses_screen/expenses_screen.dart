import 'package:flutter/material.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedMonth = 'Month';
  String _selectedYear = 'Select Year';
  
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = [
    '2022', '2023', '2024'
  ];

  // Expense data matching the image
  final Map<String, int> _expenseCategories = {
    'Feed': 8500,
    'Labour': 2500,
    'Healthcare': 1200,
    'Utilities': 3200,
    'Equipment': 15000,
  };

  int get totalExpenses => _expenseCategories.values.fold(0, (sum, amount) => sum + amount);

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
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  '₹',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month and Year Selectors
            Row(
              children: [
                Expanded(
                  child: _buildSelectorButton(
                    _selectedMonth,
                    Icons.keyboard_arrow_down,
                    () => _showMonthPicker(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectorButton(
                    _selectedYear,
                    Icons.keyboard_arrow_down,
                    () => _showYearPicker(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // This Month's Expenses
            const Text(
              "This Month's Expenses",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹ ${totalExpenses.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Expense Categories
            Expanded(
              child: Column(
                children: [
                  // First row: Feed and Labour
                  Row(
                    children: [
                      Expanded(
                        child: _buildExpenseCategoryButton('Feed', _expenseCategories['Feed']!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildExpenseCategoryButton('Labour', _expenseCategories['Labour']!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Second row: Healthcare and Utilities
                  Row(
                    children: [
                      Expanded(
                        child: _buildExpenseCategoryButton('Healthcare', _expenseCategories['Healthcare']!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildExpenseCategoryButton('Utilities', _expenseCategories['Utilities']!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                                     // Third row: Equipment (centered)
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50),
                     child: _buildExpenseCategoryButton('Equipment', _expenseCategories['Equipment']!),
                   ),
                   const SizedBox(height: 24),
                   
                   // Add Expense Button
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                       onPressed: () => _showAddExpenseDialog(context),
                       icon: const Icon(Icons.add, color: Colors.black, size: 20),
                       label: const Text(
                         'ADD EXPENSE',
                         style: TextStyle(
                           color: Colors.black,
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                         ),
                       ),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.white,
                         foregroundColor: Colors.black,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(20),
                           side: const BorderSide(color: Colors.black, width: 1),
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

  Widget _buildSelectorButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCategoryButton(String category, int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$category: ₹$amount',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _months.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_months[index]),
                onTap: () {
                  setState(() => _selectedMonth = _months[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _years.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_years[index]),
                onTap: () {
                  setState(() => _selectedYear = _years[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
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

    // Set today's date as default
    final today = DateTime.now();
    dateController.text = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';

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
                  // Date field
                  _buildExpenseField(
                    controller: dateController,
                    label: 'Date',
                    placeholder: 'dd/mm/yyyy',
                    isDateField: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Feed field
                  _buildExpenseField(
                    controller: feedController,
                    label: 'Feed',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  
                  // Labour field
                  _buildExpenseField(
                    controller: labourController,
                    label: 'Labour',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  
                  // Healthcare field
                  _buildExpenseField(
                    controller: healthcareController,
                    label: 'Healthcare',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  
                  // Utilities field
                  _buildExpenseField(
                    controller: utilitiesController,
                    label: 'Utilities',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 16),
                  
                  // Equipment field
                  _buildExpenseField(
                    controller: equipmentController,
                    label: 'Equipment',
                    placeholder: '0/-',
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Expense added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    bool isDateField = false,
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
          child: GestureDetector(
            onTap: isDateField ? () => _selectDate(context, controller) : null,
            child: TextField(
              controller: controller,
              readOnly: isDateField,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: placeholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }
}
