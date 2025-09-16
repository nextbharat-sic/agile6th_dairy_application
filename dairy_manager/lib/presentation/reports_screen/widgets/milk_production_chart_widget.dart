import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MilkProductionChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final String chartType;

  const MilkProductionChartWidget({
    super.key,
    required this.chartData,
    required this.chartType,
  });

  @override
  MilkProductionChartWidgetState createState() =>
      MilkProductionChartWidgetState();
}

class MilkProductionChartWidgetState extends State<MilkProductionChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        height: 35.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Production Trends',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildChartLegend(),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: widget.chartType == 'line'
                  ? _buildLineChart()
                  : widget.chartType == 'bar'
                      ? _buildBarChart()
                      : _buildPieChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        _buildLegendItem('Cow', AppTheme.lightTheme.colorScheme.primary),
        SizedBox(width: 3.w),
        _buildLegendItem('Buffalo', AppTheme.lightTheme.colorScheme.secondary),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.lightTheme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < widget.chartData.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      widget.chartData[value.toInt()]["day"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toInt()}L',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.lightTheme.dividerColor),
        ),
        minX: 0,
        maxX: (widget.chartData.length - 1).toDouble(),
        minY: 0,
        maxY: 30,
        lineBarsData: [
          LineChartBarData(
            spots: widget.chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value["cow"] as double);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: AppTheme.lightTheme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: widget.chartData.asMap().entries.map((entry) {
              return FlSpot(
                  entry.key.toDouble(), entry.value["buffalo"] as double);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.secondary,
                AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  strokeWidth: 2,
                  strokeColor: AppTheme.lightTheme.colorScheme.surface,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  '${flSpot.y.toStringAsFixed(1)}L',
                  AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 30,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)}L',
                AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < widget.chartData.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      widget.chartData[value.toInt()]["day"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  );
                }
                return Container();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toInt()}L',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.lightTheme.dividerColor),
        ),
        barGroups: widget.chartData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value["cow"] as double,
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 4.w,
                borderRadius: BorderRadius.circular(2),
              ),
              BarChartRodData(
                toY: entry.value["buffalo"] as double,
                color: AppTheme.lightTheme.colorScheme.secondary,
                width: 4.w,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.lightTheme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final totalCow = widget.chartData
        .fold<double>(0, (sum, item) => sum + (item["cow"] as double));
    final totalBuffalo = widget.chartData
        .fold<double>(0, (sum, item) => sum + (item["buffalo"] as double));
    final total = totalCow + totalBuffalo;

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 15.w,
        sections: [
          PieChartSectionData(
            color: AppTheme.lightTheme.colorScheme.primary,
            value: totalCow,
            title: '${((totalCow / total) * 100).toStringAsFixed(1)}%',
            radius: _touchedIndex == 0 ? 12.w : 10.w,
            titleStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
          PieChartSectionData(
            color: AppTheme.lightTheme.colorScheme.secondary,
            value: totalBuffalo,
            title: '${((totalBuffalo / total) * 100).toStringAsFixed(1)}%',
            radius: _touchedIndex == 1 ? 12.w : 10.w,
            titleStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
