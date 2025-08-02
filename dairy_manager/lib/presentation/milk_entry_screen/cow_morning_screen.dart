import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CowMorningScreen extends StatefulWidget {
  const CowMorningScreen({super.key});

  @override
  State<CowMorningScreen> createState() => _CowMorningScreenState();
}

class _CowMorningScreenState extends State<CowMorningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _milkController = TextEditingController();
  final _snfController = TextEditingController();
  final _fatController = TextEditingController();
  final _costController = TextEditingController();
  
  bool _isMorning = true;
  DateTime _selectedDate = DateTime.now();
  double _todayIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _milkController.dispose();
    _snfController.dispose();
    _fatController.dispose();
    _costController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _calculateIncome() {
    final milkQuantity = double.tryParse(_milkController.text) ?? 0.0;
    final costPerLiter = double.tryParse(_costController.text) ?? 0.0;
    
    setState(() {
      _todayIncome = milkQuantity * costPerLiter;
    });
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
      body: SafeArea(
        child: Column(
          children: [
            // Header section with back button, cow image, and settings
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/cow.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.pets,
                                  size: 40,
                                  color: AppTheme.textPrimaryColor,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cow',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
            
            // Main content card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isMorning ? Colors.white : const Color(0xFF585F65),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Toggle buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildToggleButton(
                                  'Morning',
                                  Icons.wb_sunny,
                                  true,
                                  _isMorning,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildToggleButton(
                                  'Evening',
                                  Icons.nightlight_round,
                                  false,
                                  !_isMorning,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Form fields
                          _buildFormField(
                            controller: _dateController,
                            label: 'Date',
                            hint: 'dd/mm/yyyy',
                            onTap: _selectDate,
                            readOnly: true,
                          ),
                          
                          const SizedBox(height: 20),
                          
                                                     _buildFormField(
                             controller: _milkController,
                             label: 'Milk (L)',
                             hint: 'Input Text',
                             onChanged: (value) => _calculateIncome(),
                           ),
                          
                          const SizedBox(height: 20),
                          
                          _buildFormField(
                            controller: _snfController,
                            label: 'SNF',
                            hint: 'Input Text',
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildFormField(
                            controller: _fatController,
                            label: 'Fat',
                            hint: 'Input Text',
                          ),
                          
                          const SizedBox(height: 20),
                          
                                                     _buildFormField(
                             controller: _costController,
                             label: 'Cost/L',
                             hint: 'Enter the cost',
                             suffixIcon: Icons.lock,
                             onChanged: (value) => _calculateIncome(),
                           ),
                          
                          const Spacer(),
                          
                                                     // Submit button
                           Container(
                             width: double.infinity,
                             height: 56,
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(
                                 color: AppTheme.primaryColor,
                                 width: 2,
                               ),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.black.withValues(alpha: 0.1),
                                   blurRadius: 8,
                                   offset: const Offset(0, 4),
                                 ),
                               ],
                             ),
                             child: Material(
                               color: Colors.transparent,
                               child: InkWell(
                                 onTap: _handleSubmit,
                                 borderRadius: BorderRadius.circular(16),
                                 child: Center(
                                   child: Text(
                                     'Submit',
                                     style: TextStyle(
                                       fontSize: 18,
                                       fontWeight: FontWeight.w600,
                                       color: AppTheme.textPrimaryColor,
                                     ),
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
            ),
            
            // Today's Income section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Income",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                                     Container(
                     width: double.infinity,
                     height: 60,
                     decoration: BoxDecoration(
                       color: AppTheme.backgroundColor,
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(
                         color: Colors.white,
                         width: 2,
                       ),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withValues(alpha: 0.2),
                           blurRadius: 8,
                           offset: const Offset(0, 4),
                         ),
                       ],
                     ),
                     child: Center(
                       child: Text(
                         '₹${_todayIncome.toStringAsFixed(0)}/-',
                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                           fontSize: 24,
                         ),
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

  Widget _buildToggleButton(String text, IconData icon, bool isMorning, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMorning = isMorning;
        });
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.white 
            : (_isMorning ? AppTheme.backgroundColor : const Color(0xFF585F65)),
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected 
                ? AppTheme.textPrimaryColor 
                : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected 
                  ? AppTheme.textPrimaryColor 
                  : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isMorning ? AppTheme.textPrimaryColor : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: _isMorning 
                  ? AppTheme.textSecondaryColor 
                  : Colors.white.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: _isMorning 
                ? Colors.white 
                : const Color(0xFF585F65),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: suffixIcon != null 
                ? Icon(
                    suffixIcon,
                    size: 20,
                    color: _isMorning 
                      ? AppTheme.textSecondaryColor 
                      : Colors.white.withValues(alpha: 0.7),
                  )
                : null,
            ),
            style: TextStyle(
              color: _isMorning 
                ? AppTheme.textPrimaryColor 
                : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
} 