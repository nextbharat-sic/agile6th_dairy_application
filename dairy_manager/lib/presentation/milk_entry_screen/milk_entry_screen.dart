import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/repositories/income_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../backend/services/income_service.dart';
import '../../constants/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/date_utils.dart' as DMDateUtils;

class MilkEntryScreen extends StatefulWidget {
  const MilkEntryScreen({super.key});

  @override
  _MilkEntryScreenState createState() => _MilkEntryScreenState();
}

class _MilkEntryScreenState extends State<MilkEntryScreen> {
  String? _userId;
  late IncomeService _incomeService;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _todayIncomeSub;

  // Selector types
  AnimalType selectedAnimal = AnimalType.buffalo;
  SessionType selectedSession = SessionType.morning;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController milkController = TextEditingController();
  final TextEditingController snfController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  double cowIncome = 0.0;
  double buffaloIncome = 0.0;
  
  // Lock/unlock state for cost/L field
  bool isCostLocked = false;
  double lockedCowCost = 50.0; // Default value for cow
  double lockedBuffaloCost = 60.0; // Default value for buffalo

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;

    // Initialize repositories and service
    final firestore = FirebaseFirestore.instance;
    final incomeRepo = IncomeRepository(firestore);
    final userRepo = UserRepository(firestore);
    _incomeService = IncomeService(incomeRepo: incomeRepo, userRepo: userRepo);

    // Set today's date as default
    final today = DateTime.now();
    dateController.text =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    _loadSavedCosts();
    _loadTodayIncomeInitial();
    _setupTodayIncomeListener();
  }

  @override
  void dispose() {
    _todayIncomeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadTodayIncomeInitial() async {
    if (_userId == null) return;
    final totals = await _incomeService.getTotalIncomeForDay(
      userId: _userId!,
      date: DateTime.now(),
      animalTypes: const [AnimalType.cow, AnimalType.buffalo],
    );
    if (!mounted) return;
    setState(() {
      cowIncome = totals[AnimalType.cow] ?? 0.0;
      buffaloIncome = totals[AnimalType.buffalo] ?? 0.0;
    });
  }

  void _setupTodayIncomeListener() {
    if (_userId == null) return;
    final dayStart = DMDateUtils.DateUtils.getStartOfDay(DateTime.now()).toIso8601String();
    final dayEnd = DMDateUtils.DateUtils.getEndOfDay(DateTime.now()).toIso8601String();

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('income');

    _todayIncomeSub?.cancel();
    _todayIncomeSub = userRef
        .where('dateTime', isGreaterThanOrEqualTo: dayStart)
        .where('dateTime', isLessThanOrEqualTo: dayEnd)
        .snapshots()
        .listen((snapshot) {
      double cowTotal = 0.0;
      double buffaloTotal = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final animalKey = (data['animalType'] as String?) ?? '';
        final totalIncome = (data['totalIncome'] as num?)?.toDouble() ?? 0.0;
        if (animalKey == AnimalType.cow.key) {
          cowTotal += totalIncome;
        } else if (animalKey == AnimalType.buffalo.key) {
          buffaloTotal += totalIncome;
        }
      }
      if (!mounted) return;
      setState(() {
        cowIncome = cowTotal;
        buffaloIncome = buffaloTotal;
      });
    });
  }

  Future<void> _loadSavedCosts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lockedCowCost = prefs.getDouble('locked_cow_cost') ?? 50.0;
      lockedBuffaloCost = prefs.getDouble('locked_buffalo_cost') ?? 60.0;
      isCostLocked = prefs.getBool('is_cost_locked') ?? false;
    });
    _updateCostField();
  }

  Future<void> _saveCosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('locked_cow_cost', lockedCowCost);
    await prefs.setDouble('locked_buffalo_cost', lockedBuffaloCost);
    await prefs.setBool('is_cost_locked', isCostLocked);
  }

  void _updateCostField() {
    if (!isCostLocked) return;
    final cost = selectedAnimal == AnimalType.cow ? lockedCowCost : lockedBuffaloCost;
    costController.text = cost.toStringAsFixed(0);
  }

  void _toggleCostLock() {
    setState(() {
      if (isCostLocked) {
        isCostLocked = false;
      } else {
        final currentCost = double.tryParse(costController.text) ??
            (selectedAnimal == AnimalType.cow ? lockedCowCost : lockedBuffaloCost);
        if (selectedAnimal == AnimalType.cow) {
          lockedCowCost = currentCost;
        } else {
          lockedBuffaloCost = currentCost;
        }
        isCostLocked = true;
        _saveCosts();
      }
    });
  }

  void clearFields() {
    milkController.clear();
    snfController.clear();
    fatController.clear();
    if (isCostLocked) {
      _updateCostField();
    } else {
      costController.clear();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Validate required fields
    if (milkController.text.isEmpty || costController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in Milk (L) and Cost/L fields')),
      );
      return;
    }

    try {
      // Parse date
      final dateParts = dateController.text.split('/');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      // Use current time for hour, minute, second, etc
      final now = DateTime.now();
      final selectedDate = DateTime(year, month, day, now.hour, now.minute,
          now.second, now.millisecond, now.microsecond);

      // Submit to backend using the correct method signature
      final result = await _incomeService.addIncome(
        userId: _userId!,
        dateTime: selectedDate,
        animalType: selectedAnimal,
        session: selectedSession,
        liters: double.parse(milkController.text),
        snf: double.tryParse(snfController.text) ?? 0.0,
        fat: double.tryParse(fatController.text) ?? 0.0,
        newCostPerLiter: double.parse(costController.text),
      );

      cowIncome = result.todayIncomeList[AnimalType.cow] ?? 0.0;
      buffaloIncome = result.todayIncomeList[AnimalType.buffalo] ?? 0.0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Milk entry saved successfully! Session income: ${result.totalIncomeSession}')),
      );

      // Clear fields after successful submission
      clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 100, // Increased from default ~56 to 100
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.milk} ${l10n.entry}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24, // Increased from 18 to 24
                fontWeight: FontWeight.w600, // Increased from w500 to w600
              ),
            ),
            const SizedBox(height: 8), // Increased from 4 to 8
            Image.asset(
              'assets/images/milk_entry.png',
              width: 32, // Increased from 24 to 32
              height: 32, // Increased from 24 to 32
              color: Colors.white,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,
                color: Colors.white, size: 28), // Increased from default to 28
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseCattle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _cattleToggleButton(
                    l10n.buffalo,
                    'assets/images/buffalo.png',
                    selectedAnimal == AnimalType.buffalo,
                    () {
                      setState(() {
                        selectedAnimal = AnimalType.buffalo;
                        clearFields();
                      });
                      if (isCostLocked) {
                        _updateCostField();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _cattleToggleButton(
                    l10n.cow,
                    'assets/images/cow.png',
                    selectedAnimal == AnimalType.cow,
                    () {
                      setState(() {
                        selectedAnimal = AnimalType.cow;
                        clearFields();
                      });
                      if (isCostLocked) {
                        _updateCostField();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.chooseSession,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _sessionToggleButton(
                    l10n.morning,
                    selectedSession == SessionType.morning,
                    () {
                      setState(() {
                        selectedSession = SessionType.morning;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _sessionToggleButton(
                    l10n.evening,
                    selectedSession == SessionType.evening,
                    () {
                      setState(() {
                        selectedSession = SessionType.evening;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _inputFieldRow(l10n.date, dateController, isDateField: true),
            const SizedBox(height: 8),
            _inputFieldRow(l10n.milkL, milkController,
                onChanged: (value) => ()),
            const SizedBox(height: 8),
            _inputFieldRow(l10n.snf, snfController),
            const SizedBox(height: 8),
            _inputFieldRow(l10n.fat, fatController),
            const SizedBox(height: 8),
            _inputFieldRowWithLock(l10n.costL, costController,
                onChanged: (value) {}),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60, // Set fixed height for proper alignment
              child: Stack(
                children: [
                  // Perfectly centered Submit button
                  Center(
                    child: SizedBox(
                      width: 200, // Fixed button width - adjust as needed
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.submit,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  // Edit icon positioned absolutely to the right
                  Positioned(
                    right: 10, // Distance from right edge - adjust as needed
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/milk-entry-edit'),
                        icon: const Icon(Icons.edit, color: Colors.black),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.white),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Divider(thickness: 2, color: Colors.black26),
            const SizedBox(height: 24),
            Center(
              child: Text(
                l10n.todaysIncome,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _incomeDisplay(l10n.buffalo, buffaloIncome),
                _incomeDisplay(l10n.cow, cowIncome),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _cattleToggleButton(
      String label, String iconPath, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: selected
              ? Colors.black
              : Colors.white, // SWAPPED: black when selected
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 30,
              height: 30,
              color: selected
                  ? Colors.white
                  : Colors.black, // SWAPPED: white icon when selected
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black, // SWAPPED: white text when selected
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionToggleButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected
              ? Colors.black
              : Colors.white, // CHANGED: black when selected
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.black, // CHANGED: white text when selected
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputFieldRow(String label, TextEditingController controller,
      {bool isDateField = false, Function(String)? onChanged}) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: isDateField ? () => _selectDate(context) : null,
            child: TextField(
              controller: controller,
              readOnly: isDateField,
              keyboardType: TextInputType.number,
              obscureText: false, // Always visible, never encrypted
              decoration: InputDecoration(
                hintText: isDateField ? l10n.ddmmyyyy : l10n.inputNumber,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputFieldRowWithLock(String label, TextEditingController controller,
      {Function(String)? onChanged}) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: isCostLocked,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l10n.inputNumber,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: IconButton(
                onPressed: _toggleCostLock,
                icon: Image.asset(
                  isCostLocked
                      ? 'assets/images/lock.png'
                      : 'assets/images/unlock.png',
                  width: 20,
                  height: 20,
                  color: Colors.black,
                ),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _incomeDisplay(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)}/-',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
