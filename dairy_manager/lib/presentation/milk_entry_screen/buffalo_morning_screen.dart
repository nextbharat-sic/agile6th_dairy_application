import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BuffaloMorningScreen extends StatefulWidget {
  const BuffaloMorningScreen({super.key});

  @override
  State<BuffaloMorningScreen> createState() => _BuffaloMorningScreenState();
}

class _BuffaloMorningScreenState extends State<BuffaloMorningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  final _rateController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedSession = 'Morning';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    _rateController.text = '62.0';
    _calculateAmount();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _quantityController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _rateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _calculateAmount() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    
    double amount = quantity * rate;
    
    _amountController.text = amount.toStringAsFixed(2);
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Milk entry saved successfully!'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Buffalo -  _selectedSession',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Animal Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 40,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Session Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSessionButton('Morning', Icons.wb_sunny),
                    const SizedBox(width: 16),
                    _buildSessionButton('Evening', Icons.nightlight),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Form Fields
                _buildFormField(
                  controller: _dateController,
                  label: 'Date',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: _selectDate,
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  controller: _quantityController,
                  label: 'Quantity',
                  icon: Icons.scale,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateAmount(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  controller: _fatController,
                  label: 'Fat',
                  icon: Icons.pie_chart,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateAmount(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter fat percentage';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid fat percentage';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  controller: _snfController,
                  label: 'SNF',
                  icon: Icons.science,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter SNF';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid SNF';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  controller: _rateController,
                  label: 'Rate',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateAmount(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rate';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid rate';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildFormField(
                  controller: _amountController,
                  label: 'Amount',
                  icon: Icons.calculate,
                  readOnly: true,
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Income Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'INCOME',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_amountController.text.isEmpty ? '0.00' : _amountController.text}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionButton(String session, IconData icon) {
    final isSelected = _selectedSession == session;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSession = session;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected ? AppTheme.secondaryColor : AppTheme.textSecondaryColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 32,
          color: isSelected ? AppTheme.whiteColor : AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppTheme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.textSecondaryColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.textSecondaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
        ),
      ),
    );
  }
} 