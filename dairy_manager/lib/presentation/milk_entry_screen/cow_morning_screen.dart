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
            
            // Toggle bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 80,
                child: Stack(
                  children: [
                    // Background pill
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E5E6),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    // Animated sliding white pill
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: _isMorning ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        height: 72,
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Row with icons/text and tap handlers
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isMorning = true),
                            child: SizedBox(
                              height: 80,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.wb_sunny, size: 32, color: _isMorning ? const Color(0xFF395364) : Colors.white),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Morning',
                                      style: TextStyle(
                                        color: _isMorning ? const Color(0xFF395364) : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isMorning = false),
                            child: SizedBox(
                              height: 80,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.nightlight_round, size: 32, color: !_isMorning ? const Color(0xFF395364) : Colors.white),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Evening',
                                      style: TextStyle(
                                        color: !_isMorning ? const Color(0xFF395364) : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Main content card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isMorning ? const Color(0xFFE4E5E6) : const Color(0xFF395364),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
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
                          // Form fields (unchanged, but always white background)
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
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
                                      color: _isMorning ? const Color(0xFF395364) : Colors.white,
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
            ? const Color(0xFF395364)
            : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF395364) : Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF395364),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF395364),
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