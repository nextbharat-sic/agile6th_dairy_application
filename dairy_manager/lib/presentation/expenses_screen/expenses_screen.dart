import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expenses_provider.dart';
import '../../core/models/expense.dart';

/// A clean Path-A expenses screen:
/// - One doc per category (uses provider.addBatch)
/// - Month view with range binding (inclusive)
/// - Totals + list
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  // Simple money inputs per category
  final _foodCtrl = TextEditingController();
  final _labourCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  final _utilitiesCtrl = TextEditingController();
  final _equipmentCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Bind current month on first show
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end =
          DateTime(_selectedDate.year, _selectedDate.month + 1, 0); // last day
      context.read<ExpensesProvider>().bindRange(start, end);
    });
  }

  @override
  void dispose() {
    _foodCtrl.dispose();
    _labourCtrl.dispose();
    _healthCtrl.dispose();
    _utilitiesCtrl.dispose();
    _equipmentCtrl.dispose();
    super.dispose();
  }

  double _parseMoney(String s) =>
      double.tryParse(s.replaceAll(',', '').trim()) ?? 0.0;

  Map<String, double> _collectBreakdown() {
    return <String, double>{
      'Food': _parseMoney(_foodCtrl.text),
      'Labour': _parseMoney(_labourCtrl.text),
      'Healthcare': _parseMoney(_healthCtrl.text),
      'Utilities': _parseMoney(_utilitiesCtrl.text),
      'Equipment': _parseMoney(_equipmentCtrl.text),
    }..removeWhere((_, v) => v <= 0);
  }

  Future<void> _pickMonth() async {
    final initial = _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 2, 1),
      lastDate: DateTime(initial.year + 2, 12, 31),
      helpText: 'Pick any day in the month',
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    final start = DateTime(picked.year, picked.month, 1);
    final end = DateTime(picked.year, picked.month + 1, 0);
    context.read<ExpensesProvider>().bindRange(start, end);
  }

  Future<void> _submit() async {
    final map = _collectBreakdown();
    if (map.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter at least one amount')),
      );
      return;
    }

    // Capture framework objects before await to avoid context-async lint
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await context.read<ExpensesProvider>().addBatch(
            when: _selectedDate,
            categoryToAmount: map,
          );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Expenses saved')),
      );

      // Clear inputs after success
      _foodCtrl.clear();
      _labourCtrl.clear();
      _healthCtrl.clear();
      _utilitiesCtrl.clear();
      _equipmentCtrl.clear();

      // Optionally close a dialog if this screen is shown as a modal
      // navigator.pop(); // uncomment if you present as Dialog
      (navigator); // no-op to silence analyzer if not used
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpensesProvider>();
    final items = provider.items;
    final totalsByCategory = provider.totalsByCategory();
    final overall = provider.totalAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            tooltip: 'Pick month',
            onPressed: _pickMonth,
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
          final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
          provider.bindRange(start, end);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MonthHeader(
              date: _selectedDate,
              total: overall,
              loading: provider.loading,
            ),
            const SizedBox(height: 12),
            _TotalsChips(totals: totalsByCategory),
            const SizedBox(height: 16),
            _AddCard(
              foodCtrl: _foodCtrl,
              labourCtrl: _labourCtrl,
              healthCtrl: _healthCtrl,
              utilitiesCtrl: _utilitiesCtrl,
              equipmentCtrl: _equipmentCtrl,
              onSubmit: _submit,
            ),
            const SizedBox(height: 24),
            _HistoryList(items: items),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.date,
    required this.total,
    required this.loading,
  });

  final DateTime date;
  final double total;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title =
        '${_monthName(date.month)} ${date.year} • Total ₹${total.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (loading) const SizedBox(width: 8),
          if (loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return names[(max(1, min(12, m)) - 1)];
  }
}

class _TotalsChips extends StatelessWidget {
  const _TotalsChips({required this.totals});
  final Map<String, double> totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (totals.isEmpty) {
      return Text(
        'No expenses this month yet.',
        style: theme.textTheme.bodyMedium,
      );
    }
    final entries = totals.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in entries)
          Chip(
            label: Text('${e.key}: ₹${e.value.toStringAsFixed(2)}'),
            backgroundColor:
                theme.colorScheme.secondary.withValues(alpha: 0.10),
            side: BorderSide(
              color: theme.colorScheme.secondary.withValues(alpha: 0.20),
            ),
          ),
      ],
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({
    required this.foodCtrl,
    required this.labourCtrl,
    required this.healthCtrl,
    required this.utilitiesCtrl,
    required this.equipmentCtrl,
    required this.onSubmit,
  });

  final TextEditingController foodCtrl;
  final TextEditingController labourCtrl;
  final TextEditingController healthCtrl;
  final TextEditingController utilitiesCtrl;
  final TextEditingController equipmentCtrl;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    Widget moneyField(String label, TextEditingController c) {
      return TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          border: const OutlineInputBorder(),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Add expenses', style: labelStyle),
            ),
            const SizedBox(height: 12),
            moneyField('Food', foodCtrl),
            const SizedBox(height: 8),
            moneyField('Labour', labourCtrl),
            const SizedBox(height: 8),
            moneyField('Healthcare', healthCtrl),
            const SizedBox(height: 8),
            moneyField('Utilities', utilitiesCtrl),
            const SizedBox(height: 8),
            moneyField('Equipment', equipmentCtrl),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});
  final List<Expense> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No entries found for this range.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final e in items)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title:
                  Text('${e.category} • ₹${e.totalAmount.toStringAsFixed(2)}'),
              subtitle: Text(
                '${e.timestampLocal.year}-${e.timestampLocal.month.toString().padLeft(2, '0')}-${e.timestampLocal.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
      ],
    );
  }
}
