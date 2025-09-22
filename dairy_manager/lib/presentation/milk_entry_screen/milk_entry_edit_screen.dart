import 'package:dairy_manager/backend/services/income_service.dart';
import 'package:dairy_manager/models/income_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide DateUtils;
import '../../backend/repositories/income_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/date_utils.dart';
import '../../l10n/app_localizations.dart'; // Add this import

class MilkEntryEditScreen extends StatefulWidget {
  const MilkEntryEditScreen({super.key});

  @override
  State<MilkEntryEditScreen> createState() => _MilkEntryEditScreenState();
}

class _MilkEntryEditScreenState extends State<MilkEntryEditScreen> {
  AnimalType selectedAnimal = AnimalType.buffalo;
  SessionType selectedSession = SessionType.morning;
  String? _userId;
  late IncomeService _incomeService;
  List<EntryData> _entries = []; // 0: Today, 1: Yesterday, 2: Day before
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    
    // Initialize repositories and service
    final firestore = FirebaseFirestore.instance;
    final incomeRepo = IncomeRepository(firestore);
    final userRepo = UserRepository(firestore);
    _incomeService = IncomeService(incomeRepo: incomeRepo, userRepo: userRepo);
    
    // Load entries after the first frame is rendered (when context is available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIncomeEntries();
    });
  }

  Future<void> _loadIncomeEntries() async {
    if (_userId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now();
      final l10n = AppLocalizations.of(context);
      List<EntryData> entries = [];
      
      for (int i = 0; i < 3; i++) {
        final targetDate = today.subtract(Duration(days: i));
        final targetDateStart = DateUtils.getStartOfDay(targetDate);
        final targetDateEnd = DateUtils.getEndOfDay(targetDate);
        
        // Get entries for this specific date, animal type, and session
        final dayEntries = await _incomeService.getIncomeEntriesForDateRange(
          startDate: targetDateStart,
          endDate: targetDateEnd,
          userId: _userId!,
          animalType: selectedAnimal,
          sessionType: selectedSession,
        );
        
        // Find entry for this specific combination
        IncomeModel? existingEntry;
        if (dayEntries.isNotEmpty) {
          existingEntry = dayEntries.first;
        }

        // Localized labels
        String label;
        if (i == 0) {
          label = l10n?.today ?? 'Today';
        } else if (i == 1) {
          label = l10n?.yesterday ?? 'Yesterday';
        } else {
          label = l10n?.dayBeforeYesterday ?? 'Day before yesterday';
        }

        entries.add(EntryData(
          label: label,
          date: _formatDateForDisplay(i), // Changed to dd/mm/yyyy format
          actualDate: targetDate,
          incomeModel: existingEntry,
          hasData: existingEntry != null && existingEntry.id.isNotEmpty,
        ));
      }

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Create empty entries if error occurs
        final l10n = AppLocalizations.of(context);
        _entries = List.generate(3, (i) {
          String label;
          if (i == 0) {
            label = l10n?.today ?? 'Today';
          } else if (i == 1) {
            label = l10n?.yesterday ?? 'Yesterday';
          } else {
            label = l10n?.dayBeforeYesterday ?? 'Day before yesterday';
          }
          
          return EntryData(
            label: label,
            date: _formatDateForDisplay(i),
            actualDate: DateTime.now().subtract(Duration(days: i)),
            incomeModel: null,
            hasData: false,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.editEntry,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.chooseCattle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _cattleToggle(
                        l10n.buffalo,
                        'assets/images/buffalo.png',
                        selectedAnimal == AnimalType.buffalo,
                        () {
                          setState(() => selectedAnimal = AnimalType.buffalo);
                          _loadIncomeEntries();
                        })),
                const SizedBox(width: 8),
                Expanded(
                    child: _cattleToggle(
                        l10n.cow,
                        'assets/images/cow.png',
                        selectedAnimal == AnimalType.cow,
                        () {
                          setState(() => selectedAnimal = AnimalType.cow);
                          _loadIncomeEntries();
                        })),
              ]),
              const SizedBox(height: 16),
              Text(l10n.chooseSession,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _sessionToggle(
                        l10n.morning,
                        selectedSession == SessionType.morning,
                        () {
                          setState(() => selectedSession = SessionType.morning);
                          _loadIncomeEntries();
                        })),
                const SizedBox(width: 8),
                Expanded(
                    child: _sessionToggle(
                        l10n.evening,
                        selectedSession == SessionType.evening,
                        () {
                          setState(() => selectedSession = SessionType.evening);
                          _loadIncomeEntries();
                        })),
              ]),
              const SizedBox(height: 16),
              
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                for (int i = 0; i < _entries.length; i++) _entryTile(i),
              
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Updated to format as dd/mm/yyyy for display
  String _formatDateForDisplay(int daysAgo) {
    final d = DateTime.now().subtract(Duration(days: daysAgo));
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Widget _entryTile(int index) {
  final entry = _entries[index];
  final l10n = AppLocalizations.of(context)!;
  
  // Get localized labels dynamically based on index instead of stored labels
  String localizedLabel;
  if (index == 0) {
    localizedLabel = l10n.today;
  } else if (index == 1) {
    localizedLabel = l10n.yesterday;
  } else {
    localizedLabel = l10n.dayBeforeYesterday;
  }
  
  // Display "--" for missing data or actual values
  String milk = '--';
  String snf = '--';
  String fat = '--';
  String cost = '--';
  
  if (entry.hasData && entry.incomeModel != null) {
    // Only convert to string if values are not null and not NaN
    final model = entry.incomeModel!;
    
    milk = (!model.liters.isNaN) 
        ? model.liters.toString() 
        : '--';
    snf = (!model.snf.isNaN) 
        ? model.snf.toString() 
        : '--';
    fat = (!model.fat.isNaN) 
        ? model.fat.toString() 
        : '--';
    cost = (!model.costPerLiter.isNaN) 
        ? model.costPerLiter.toString() 
        : '--';
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: GestureDetector(
      onTap: () async {
        final updated = await _openEditBottomSheet(entry);
        if (updated && mounted) {
          _loadIncomeEntries();
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricHeader(l10n.milkL),
                _MetricHeader(l10n.snfHeader),
                _MetricHeader(l10n.fatHeader),
                _MetricHeader(l10n.costPerL),
              ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricValue(milk),
                _MetricValue(snf),
                _MetricValue(fat),
                _MetricValue(cost),
              ]),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizedLabel, // Use dynamically generated localized label
                    style: const TextStyle(color: Colors.white70, fontSize: 16)),
                Text(entry.date, // Date remains the same
                    style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ]),
          ]),
      ),
    ),
  );
}


  Future<bool> _openEditBottomSheet(EntryData entryData) {
    final l10n = AppLocalizations.of(context)!;
    final dateCtrl = TextEditingController(text: entryData.date); // Now in dd/mm/yyyy format

    String milkText = '';
    String snfText = '';
    String fatText = '';
    String costText = '';
    
    if (entryData.hasData && entryData.incomeModel != null) {
      final model = entryData.incomeModel!;
      milkText = (!model.liters.isNaN) ? model.liters.toString() : '';
      snfText = (!model.snf.isNaN) ? model.snf.toString() : '';
      fatText = (!model.fat.isNaN) ? model.fat.toString() : '';
      costText = (!model.costPerLiter.isNaN) ? model.costPerLiter.toString() : '';
    }
    
    final milkCtrl = TextEditingController(text: milkText);
    final snfCtrl = TextEditingController(text: snfText);
    final fatCtrl = TextEditingController(text: fatText);
    final costCtrl = TextEditingController(text: costText);

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(l10n.editEntry,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18))),
                  ]),
                const SizedBox(height: 12),
                _fieldRow(l10n.date, dateCtrl, isDate: true),
                const SizedBox(height: 8),
                _fieldRow('${l10n.milk} (L)', milkCtrl),
                const SizedBox(height: 8),
                _fieldRow(l10n.snf, snfCtrl),
                const SizedBox(height: 8),
                _fieldRow(l10n.fat, fatCtrl),
                const SizedBox(height: 8),
                _fieldRow(l10n.costPerL, costCtrl, lockIcon: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(entryData, dateCtrl,
                        milkCtrl, snfCtrl, fatCtrl, costCtrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(color: Colors.black)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.submit,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _handleSubmit(
      EntryData entryData,
      TextEditingController dateCtrl,
      TextEditingController milkCtrl,
      TextEditingController snfCtrl,
      TextEditingController fatCtrl,
      TextEditingController costCtrl) async {
    
    final l10n = AppLocalizations.of(context)!;
    
    // Validate only mandatory inputs - MILK and COST are required, SNF and FAT are optional
    if (milkCtrl.text.isEmpty || costCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillMilkAndCost)),
      );
      return;
    }

    try {
      final costPerLiter = double.parse(costCtrl.text);
      final liters = double.parse(milkCtrl.text);
      
      // Parse SNF and Fat, default to 0 if empty
      final snf = snfCtrl.text.isEmpty ? 0.0 : double.parse(snfCtrl.text);
      final fat = fatCtrl.text.isEmpty ? 0.0 : double.parse(fatCtrl.text);

      await _incomeService.saveIncomeEntry(
        userId: _userId!,
        existingIncomeId: (entryData.hasData && entryData.incomeModel != null) 
            ? entryData.incomeModel!.id 
            : null,
        dateTime: entryData.actualDate,
        animalType: selectedAnimal,
        session: selectedSession,
        liters: liters,
        snf: snf,
        fat: fat,
        newCostPerLiter: costPerLiter,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.entrySavedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorSavingEntry}: $e')),
        );
      }
    }
  }

  Widget _fieldRow(String label, TextEditingController ctrl,
      {bool isDate = false, bool lockIcon = false}) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: ctrl,
            readOnly: isDate,
            keyboardType: isDate ? TextInputType.none : TextInputType.number,
            decoration: InputDecoration(
              hintText: isDate ? 'dd/mm/yyyy' : l10n.inputText,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Colors.black54)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Colors.black54)),
              suffixIcon:
                  lockIcon ? const Icon(Icons.lock_outline_rounded) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cattleToggle(
          String label, String iconPath, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 1)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(iconPath,
                width: 26,
                height: 26,
                color: selected ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18)),
          ]),
        ),
      );

  Widget _sessionToggle(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 1)),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 18))),
        ),
      );
}

// Data class to hold entry information
class EntryData {
  final String label;
  final String date;
  final DateTime actualDate;
  final IncomeModel? incomeModel;
  final bool hasData;

  EntryData({
    required this.label,
    required this.date,
    required this.actualDate,
    required this.incomeModel,
    required this.hasData,
  });
}

class _MetricHeader extends StatelessWidget {
  const _MetricHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style:
          const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 18));
}

class _MetricValue extends StatelessWidget {
  const _MetricValue(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
}
