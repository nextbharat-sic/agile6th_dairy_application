import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/repositories/income_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../backend/services/income_service.dart';
import '../../constants/constants.dart';
import '../../l10n/app_localizations.dart';

class MilkEntryScreen extends StatefulWidget {
  const MilkEntryScreen({Key? key}) : super(key: key);

  @override
  _MilkEntryScreenState createState() => _MilkEntryScreenState();
}

class _MilkEntryScreenState extends State<MilkEntryScreen> {
  String? _userId;
  late IncomeService _incomeService;
  
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
    dateController.text = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
  }

  void calculateIncome() {
    final milk = double.tryParse(milkController.text) ?? 0.0;
    final costPerLitre = double.tryParse(costController.text) ?? 0.0;
    final amount = milk * costPerLitre;

    setState(() {
      if (selectedAnimal == AnimalType.cow) {
        cowIncome = amount;
        buffaloIncome = 0.0; // Show zero for buffalo when cow is selected
      } else {
        buffaloIncome = amount;
        cowIncome = 0.0; // Show zero for cow when buffalo is selected
      }
    });
  }

  void clearFields() {
    milkController.clear();
    snfController.clear();
    fatController.clear();
    costController.clear();
    setState(() {
      cowIncome = 0.0;
      buffaloIncome = 0.0;
    });
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
        dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
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
        const SnackBar(content: Text('Please fill in Milk (L) and Cost/L fields')),
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
      final selectedDate = DateTime(year, month, day, now.hour, now.minute, now.second, now.millisecond, now.microsecond);

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Milk entry saved successfully! Session income: ${result['totalIncomeSession']}')),
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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.milk + ' ' + l10n.entry,
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
            icon: const Icon(Icons.settings, color: Colors.white, size: 28), // Increased from default to 28
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
            _inputFieldRow(l10n.milkL, milkController, onChanged: (value) => calculateIncome()),
            const SizedBox(height: 8),
            _inputFieldRow(l10n.snf, snfController),
            const SizedBox(height: 8),
            _inputFieldRow(l10n.fat, fatController),
            const SizedBox(height: 8),
            _inputFieldRow(l10n.costL, costController, onChanged: (value) => calculateIncome()),
            const SizedBox(height: 20),
            Container(
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
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                      onPressed: () => Navigator.pushNamed(context, '/milk-entry-edit'),
                      icon: const Icon(Icons.edit, color: Colors.black),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.black, width: 1),
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
            const Center(
              child: Text(
                'TODAY\'S INCOME',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _incomeDisplay('Cow', cowIncome),
                _incomeDisplay('Buffalo', buffaloIncome),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _cattleToggleButton(String label, String iconPath, bool selected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 70,
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.white, // SWAPPED: black when selected
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
            color: selected ? Colors.white : Colors.black, // SWAPPED: white icon when selected
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black, // SWAPPED: white text when selected
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
        color: selected ? Colors.black : Colors.white, // CHANGED: black when selected
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black, // CHANGED: white text when selected
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
              hintText: isDateField ? l10n.ddmmyyyy : l10n.inputText,
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
            onChanged: onChanged,
          ),
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
            fontSize: 16,
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
