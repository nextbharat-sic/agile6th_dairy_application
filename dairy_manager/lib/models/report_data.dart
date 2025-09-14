class ReportData {
  final String period;
  final double cowMilk;
  final double cowSnf;
  final double cowFat;
  final double buffaloMilk;
  final double buffaloSnf;
  final double buffaloFat;

  ReportData({
    required this.period,
    required this.cowMilk,
    required this.cowSnf,
    required this.cowFat,
    required this.buffaloMilk,
    required this.buffaloSnf,
    required this.buffaloFat,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      period: json['period'] ?? '',
      cowMilk: (json['cowMilk'] as num?)?.toDouble() ?? 0.0,
      cowSnf: (json['cowSnf'] as num?)?.toDouble() ?? 0.0,
      cowFat: (json['cowFat'] as num?)?.toDouble() ?? 0.0,
      buffaloMilk: (json['buffaloMilk'] as num?)?.toDouble() ?? 0.0,
      buffaloSnf: (json['buffaloSnf'] as num?)?.toDouble() ?? 0.0,
      buffaloFat: (json['buffaloFat'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class IncomeSummary {
  final double expense;
  final double income;
  final double profit;

  IncomeSummary({
    required this.expense,
    required this.income,
    required this.profit,
  });

  factory IncomeSummary.fromJson(Map<String, dynamic> json) {
    return IncomeSummary(
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
