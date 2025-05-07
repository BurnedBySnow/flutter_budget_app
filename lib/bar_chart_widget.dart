import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> categoryTotals;

  BarChartWidget({required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: barTouchData,
                borderData: FlBorderData(show: false),
                barGroups:
                    categoryTotals.entries.map((entry) {
                      int index = categoryTotals.keys.toList().indexOf(
                        entry.key,
                      );
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(toY: entry.value, color: Color(0xFFe78a4e)),
                        ],
                        showingTooltipIndicators: [0],
                      );
                    }).toList(),
                gridData: FlGridData(show: false),
                minY: 0,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          space: 8,
                          meta: meta,
                          child: Text(
                            categoryTotals.keys.elementAt(value.toInt()),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (
        BarChartGroupData group,
        int groupIndex,
        BarChartRodData rod,
        int rodIndex,
      ) {
        return BarTooltipItem(
          rod.toY.round().toString(),
          const TextStyle(color: Color(0xFFe78a4e), fontWeight: FontWeight.bold),
        );
      },
    ),
  );
}
