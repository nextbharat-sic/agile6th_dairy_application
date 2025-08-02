import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MonthlySummaryChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlySummaryChartWidget({
    super.key,
    required this.monthlyData,
  });

  @override
  Widget build(BuildContext context) {
    final maxAmount = (monthlyData as List)
        .map((data) => data["amount"] as double)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
        width: double.infinity,
        height: 25.h,
        child: Semantics(
            label: "Monthly Expenses Bar Chart",
            child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.2,
                barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final month =
                              monthlyData[group.x.toInt()]["month"] as String;
                          final amount = rod.toY;
                          return BarTooltipItem(
                              '$month\n₹${amount.toStringAsFixed(0)}',
                              TextStyle(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp));
                        })),
                titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < monthlyData.length) {
                                return Padding(
                                    padding: EdgeInsets.only(top: 1.h),
                                    child: Text(
                                        monthlyData[index]["month"] as String,
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.onSurface
                                                    .withValues(alpha: 0.7))));
                              }
                              return Text('');
                            },
                            reservedSize: 3.h)),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            interval: maxAmount / 4,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                  '₹${(value / 1000).toStringAsFixed(0)}K',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.7)));
                            },
                            reservedSize: 8.w))),
                borderData: FlBorderData(
                    show: true,
                    border: Border(
                        bottom: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                            width: 1),
                        left: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                            width: 1))),
                barGroups: (monthlyData as List).asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final amount = data["amount"] as double;

                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                        toY: amount,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 6.w,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxAmount * 1.2,
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1))),
                  ]);
                }).toList(),
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxAmount / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                          strokeWidth: 1);
                    })))));
  }
}
