import 'package:dairy_manager/backend/services/income_service.dart';
import 'package:dairy_manager/models/income_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide DateUtils;
import '../../backend/repositories/income_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/date_utils.dart';
import '../../l10n/app_localizations.dart';

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

  List<IncomeModel> _entries = []; // 0: Today, 1: Yesterday, 2: Day before

  @override
  void initState() {
    super.initState();

    // Initialize repositories and service
    final firestore = FirebaseFirestore.instance;
    final incomeRepo = IncomeRepository(firestore);
    final userRepo = UserRepository(firestore);
    _incomeService = IncomeService(incomeRepo: incomeRepo, userRepo: userRepo);

    _loadIncomeEntries();

    // _entries = [
    //   {
    //     'label': 'Today',
    //     'date': _formatRelativeDate(0),
    //     'milk': '35',
    //     'snf': '8.5',
    //     'fat': '3.1',
    //     'cost': '45',
    //   },
    //   {
    //     'label': 'Yesterday',
    //     'date': _formatRelativeDate(1),
    //     'milk': '20',
    //     'snf': '8',
    //     'fat': '3',
    //     'cost': '45',
    //   },
    //   {
    //     'label': 'Day before yesterday',
    //     'date': _formatRelativeDate(2),
    //     'milk': '28',
    //     'snf': '7.5',
    //     'fat': '2.6',
    //     'cost': '40',
    //   },
    // ];
  }

  Future<void> _loadIncomeEntries() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;

    final today = DateUtils.getToday();
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));
    final startDate = DateUtils.getStartOfDay(dayBeforeYesterday);
    final endDate = DateUtils.getEndOfDay(today);

    final response = await _incomeService.getIncomeEntriesForDateRange(
      startDate: startDate,
      endDate: endDate,
      userId: _userId!,
      animalType: selectedAnimal,
      sessionType: selectedSession,
    );

    if (!mounted) return;
    setState(() {
      _entries = response;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context)!.editEntry,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.settings, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.chooseCattle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _cattleToggle(
                        AppLocalizations.of(context)!.buffaloLabel,
                        'assets/images/buffalo.png',
                        selectedAnimal == AnimalType.buffalo,
                        () => setState(
                            () => selectedAnimal = AnimalType.buffalo))),
                const SizedBox(width: 8),
                Expanded(
                    child: _cattleToggle(
                        AppLocalizations.of(context)!.cowLabel,
                        'assets/images/cow.png',
                        selectedAnimal == AnimalType.cow,
                        () => setState(() => selectedAnimal = AnimalType.cow))),
              ]),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.chooseSession,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _sessionToggle(
                        AppLocalizations.of(context)!.morning,
                        selectedSession == SessionType.morning,
                        () => setState(
                            () => selectedSession = SessionType.morning))),
                const SizedBox(width: 8),
                Expanded(
                    child: _sessionToggle(
                        AppLocalizations.of(context)!.evening,
                        selectedSession == SessionType.evening,
                        () => setState(
                            () => selectedSession = SessionType.evening))),
              ]),
              const SizedBox(height: 16),
              for (int i = 0; i < _entries.length; i++) _entryTile(i),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }


  Widget _entryTile(int index) {
    final e = _entries[index];
    String label;
    if (index == 0) {
      label = AppLocalizations.of(context)!.today;
    } else if (index == 1) {
      label = AppLocalizations.of(context)!.yesterday;
    } else {
      label = AppLocalizations.of(context)!.dayBeforeYesterday;
    }

    final date = DateUtils.convertToDateString(
        e.dateTime); // Keep as is, date is not nullable
    final milk = e.liters.isNaN ? '--' : e.liters.toString();
    final snf = e.snf.isNaN ? '--' : e.snf.toString();
    final fat = e.fat.isNaN ? '--' : e.fat.toString();
    final cost = e.costPerLiter.isNaN ? '--' : e.costPerLiter.toString();
    final incomeId = e.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () async {
          final updated = await _openEditBottomSheet(
              label, date, milk, snf, fat, cost, incomeId);
          if (updated != null && mounted) {
            setState(() {
              _entries[index] = updated;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 6)),
              ]),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricHeader(AppLocalizations.of(context)!.milkL),
                  _MetricHeader(AppLocalizations.of(context)!.snfPercent),
                  _MetricHeader(AppLocalizations.of(context)!.fatPercent),
                  _MetricHeader(AppLocalizations.of(context)!.costPerL),
                ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _MetricValue(milk),
              _MetricValue(snf),
              _MetricValue(fat),
              _MetricValue(cost),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(date,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<IncomeModel?> _openEditBottomSheet(String label, String date,
      String milk, String snf, String fat, String cost, String incomeId) {
    final dateCtrl = TextEditingController(text: date);
    final milkCtrl = TextEditingController(text: milk);
    final snfCtrl = TextEditingController(text: snf);
    final fatCtrl = TextEditingController(text: fat);
    final costCtrl = TextEditingController(text: cost);

    return showModalBottomSheet<IncomeModel>(
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
                Row(children: [
                  Expanded(
                      child: Text(AppLocalizations.of(context)!.editEntry,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16))),
                ]),
                const SizedBox(height: 12),
                _fieldRow(AppLocalizations.of(context)!.date, dateCtrl, isDate: true),
                const SizedBox(height: 8),
                _fieldRow(AppLocalizations.of(context)!.milkL, milkCtrl),
                const SizedBox(height: 8),
                _fieldRow(AppLocalizations.of(context)!.snfPercent, snfCtrl),
                const SizedBox(height: 8),
                _fieldRow(AppLocalizations.of(context)!.fatPercent, fatCtrl),
                const SizedBox(height: 8),
                _fieldRow(AppLocalizations.of(context)!.costPerL, costCtrl, lockIcon: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(label, dateCtrl, milkCtrl,
                        snfCtrl, fatCtrl, costCtrl, incomeId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(color: Colors.black)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Submit',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(
      String label,
      TextEditingController dateCtrl,
      TextEditingController milkCtrl,
      TextEditingController snfCtrl,
      TextEditingController fatCtrl,
      TextEditingController costCtrl,
      String incomeId) async {
    final costPerLitre = double.parse(costCtrl.text);
    final litres = double.parse(milkCtrl.text);
    final snf = double.tryParse(snfCtrl.text) ?? 0.0;
    final fat = double.tryParse(fatCtrl.text) ?? 0.0;
    final updatedIncomeEntry = await _incomeService.saveIncomeEntry(
      userId: _userId!,
      existingIncomeId: incomeId,
      dateTime: DateTime.parse(dateCtrl.text),
      animalType: selectedAnimal,
      session: selectedSession,
      liters: litres,
      snf: snf,
      fat: fat,
      newCostPerLiter: costPerLitre,
    );
    Navigator.pop(context, updatedIncomeEntry);
  }

  Widget _fieldRow(String label, TextEditingController ctrl,
      {bool isDate = false, bool lockIcon = false}) {
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
            decoration: InputDecoration(
              hintText: isDate ? 'dd/mm/yyyy' : 'Input Text',
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
                    fontWeight: FontWeight.w600)),
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
                      fontWeight: FontWeight.w600))),
        ),
      );
}

class _MetricHeader extends StatelessWidget {
  const _MetricHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style:
          const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600));
}

class _MetricValue extends StatelessWidget {
  const _MetricValue(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
}
