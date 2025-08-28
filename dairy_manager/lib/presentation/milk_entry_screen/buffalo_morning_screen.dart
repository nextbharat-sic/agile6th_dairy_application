import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide DateUtils;
import '../../backend/repositories/income_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../backend/services/income_service.dart';
import '../../constants/constants.dart';
import '../../theme/app_theme.dart';

class BuffaloMorningScreen extends StatefulWidget {
  const BuffaloMorningScreen({super.key});

  @override
  State<BuffaloMorningScreen> createState() => _BuffaloMorningScreenState();
}

class _BuffaloMorningScreenState extends State<BuffaloMorningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _milkController = TextEditingController();
  final _snfController = TextEditingController();
  final _fatController = TextEditingController();
  final _costController = TextEditingController();


  bool _isMorning = true;
  DateTime _selectedDate = DateTime.now();
  double _todayIncome = 0.0;

  late IncomeService _incomeService;
  late String _userId; // Set this appropriately in your authentication logic.


  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    // Initialize services
    final firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final incomeRepo = IncomeRepository(firestore);
    final userRepo = UserRepository(firestore);
    _incomeService = IncomeService(incomeRepo: incomeRepo, userRepo: userRepo);

     // Set _userId from your authentication layer
    final User? user = auth.currentUser;

    if (user != null) {
      _userId = user.uid; // <-- This is the Firebase UID
    }
    else {
      // TODO
      // Handle the case where the user is not logged in,
      // perhaps by redirecting to a login screen or showing an error.
      // For now, we'll throw an error or assign a default/guest ID if applicable.
      // This part depends on your app's authentication flow.
      // For this example, let's assume _userId must be set.
      // If a guest mode or default is needed, adjust accordingly.
      print("User not logged in!"); // Or handle more gracefully
      // As a fallback, if critical, you might prevent screen usage or pop
      // Navigator.pop(context);
      // throw Exception("User ID not available"); // Or set a default/guest ID
    }
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

  Future<void> _handleSubmit() async  {
    if (!_formKey.currentState!.validate()) return;

    final animalType = AnimalType.buffalo;
    final session = _isMorning ? SessionType.morning : SessionType.evening;
    final liters = double.tryParse(_milkController.text) ?? 0.0;
    final snf = double.tryParse(_snfController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;
    final costPerLiter = double.tryParse(_costController.text) ?? 0.0;

    try {
      final result = await _incomeService.addIncome(
        userId: _userId,
        dateTime: _selectedDate,
        animalType: animalType,
        session: session,
        liters: liters,
        snf: snf,
        fat: fat,
        newCostPerLiter: costPerLiter,
      );
      // Show success message and update daily income

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Entry saved! Session income: ₹${result['totalIncomeSession'].toStringAsFixed(2)}, Day total: ₹${result['totalIncomeDay'].toStringAsFixed(2)}"),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      Navigator.pop(context); // Clean navigation after success
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save milk entry: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section with back button, buffalo image, and settings
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
                              'assets/images/buffalo.png',
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
                          'Buffalo',
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
                          color: Colors.black.withValues(alpha: 50),
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
                ? const Color(0xFF395364)
                : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected 
                  ? const Color(0xFF395364)
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
                  : Colors.white.withAlpha(180),
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
                      : Colors.white.withAlpha(180),
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