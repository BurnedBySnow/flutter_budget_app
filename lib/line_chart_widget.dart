import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatelessWidget {
  final Map<String, double> monthlyTotals;

  LineChartWidget({required this.monthlyTotals});

  bool showAvg = false;

  String _formatNumberWithK(double number) {
    if (number >= 1000) {
      double valueInThousands = number / 1000;

      return valueInThousands == valueInThousands.roundToDouble()
          ? '${valueInThousands.toInt()}k'
          : '${valueInThousands.toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  int _calculateMaxValue(Iterable<double> numbers) {
    double max = numbers.reduce((a, b) => a > b ? a : b);
    int digits = _countDigits(max.toInt());
    debugPrint(max.toString());
    debugPrint(digits.toString());
    debugPrint(pow(10, digits).toString());
    return (max / pow(10,digits)).ceil() * pow(10, digits).toInt();
  }

  int _countDigits(int number) {
    debugPrint(number.toInt().toString());
    return '$number'.length - 1; 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(showAvg ? mainData() : mainData()),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    int index = value.toInt();
    if (index < 0 || index >= monthlyTotals.keys.length) {
      return Text('');
    }

    String month = monthlyTotals.keys.elementAt(index);
    Widget text = Text(
      DateFormat('MMM yy').format(DateTime.parse('$month-01')),
      style: style,
    );
    return SideTitleWidget(meta: meta, child: text);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text = _formatNumberWithK(value);

    return Text(text, style: style);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: true),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xFF32302f)),
      ),
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY:
          monthlyTotals.values.isNotEmpty
              ? _calculateMaxValue(monthlyTotals.values).toDouble()
              : 100,
      lineBarsData: [
        LineChartBarData(
          spots:
              monthlyTotals.entries.map((entry) {
                int index = monthlyTotals.keys.toList().indexOf(entry.key);
                return FlSpot(index.toDouble(), entry.value);
              }).toList(),
          // isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
