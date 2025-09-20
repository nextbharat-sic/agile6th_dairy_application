import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide DateUtils;
import '../../backend/repositories/income_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../backend/services/income_service.dart';
import '../../constants/constants.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

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
  String? _userId;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    // Initialize services
    final firestore = FirebaseFirestore.instance;
    final incomeRepo = IncomeRepository(firestore);
    final userRepo = UserRepository(firestore);
    _incomeService = IncomeService(incomeRepo: incomeRepo, userRepo: userRepo);

    // Set _userId from your authentication layer
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchTodayIncome();
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
      await _fetchTodayIncome(); // Refresh today's income for new date
    }
  }

  Future<void> _fetchTodayIncome() async {
    if (_userId == null) {
      setState(() {
        _todayIncome = 0.0;
      });
      return;
    }
    try {
      final total = await _incomeService.getTotalIncomeForDay(
        userId: _userId!,
        date: _selectedDate,
        animalTypes: [AnimalType.buffalo],
      );
      setState(() {
        _todayIncome = 0.0;
      });
    } catch (_) {
      setState(() {
        _todayIncome = 0.0;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit milk entries.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill Milk (L) and Cost/L fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final animalType = AnimalType.buffalo;
    final session = _isMorning ? SessionType.morning : SessionType.evening;
    final liters = double.tryParse(_milkController.text) ?? 0.0;
    final snf = double.tryParse(_snfController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;
    final costPerLiter = double.tryParse(_costController.text) ?? 0.0;

    try {
      final result = await _incomeService.addIncome(
        userId: _userId!,
        dateTime: _selectedDate,
        animalType: animalType,
        session: session,
        liters: liters,
        snf: snf,
        fat: fat,
        newCostPerLiter: costPerLiter,
      );
      await _fetchTodayIncome();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(""),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
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
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/images/buffalo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.pets,
                                      size: 24,
                                      color: AppTheme.textPrimaryColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ఎద్దు',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings,
                            color: Colors.white, size: 24),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                ),
                // Toggle bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      children: [
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E5E6),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: _isMorning
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 24,
                            height: 40,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isMorning = true),
                                child: SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.wb_sunny,
                                            size: 20,
                                            color: _isMorning
                                                ? const Color(0xFF395364)
                                                : Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ఉదయం',
                                          style: TextStyle(
                                            color: _isMorning
                                                ? const Color(0xFF395364)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                                  height: 48,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.nightlight_round,
                                            size: 20,
                                            color: !_isMorning
                                                ? const Color(0xFF395364)
                                                : Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          'సాయంత్రం',
                                          style: TextStyle(
                                            color: !_isMorning
                                                ? const Color(0xFF395364)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                const SizedBox(height: 8),
                // Main content card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isMorning
                        ? const Color(0xFFE4E5E6)
                        : const Color(0xFF395364),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFormField(
                            controller: _dateController,
                            label: 'తేదీ',
                            hint: 'dd/mm/yyyy',
                            onTap: _selectDate,
                            readOnly: true,
                          ),
                          const SizedBox(height: 10),
                          _buildFormField(
                            controller: _milkController,
                            label: 'పాలు (లీ)',
                            hint: 'Input Text',
                            onChanged: (value) => _calculateIncome(),
                            isRequired: true,
                          ),
                          const SizedBox(height: 10),
                          _buildFormField(
                            controller: _snfController,
                            label: 'SNF',
                            hint: 'Input Text',
                          ),
                          const SizedBox(height: 10),
                          _buildFormField(
                            controller: _fatController,
                            label: 'కొవ్వు',
                            hint: 'Input Text',
                          ),
                          const SizedBox(height: 10),
                          _buildFormField(
                            controller: _costController,
                            label: 'ఖర్చు/లీ',
                            hint: 'ఖర్చును నమోదు చేయండి',
                            suffixIcon: Icons.lock,
                            onChanged: (value) => _calculateIncome(),
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleSubmit,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _isMorning
                                          ? const Color(0xFF395364)
                                          : Colors.white,
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
                const SizedBox(height: 12),
                // Today's Income section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.todaysIncome,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            '\u20b9${_todayIncome.toStringAsFixed(0)}/-',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
    bool isRequired = false,
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
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'అవసరం';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: _isMorning
                    ? AppTheme.textSecondaryColor
                    : Colors.white.withAlpha(180),
              ),
              filled: true,
              fillColor: _isMorning ? Colors.white : const Color(0xFF585F65),
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
              color: _isMorning ? AppTheme.textPrimaryColor : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
