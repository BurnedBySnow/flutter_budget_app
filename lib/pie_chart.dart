import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_budget_app/indicator.dart';

class PieChartWidget extends StatefulWidget {
  PieChartWidget({required this.categoryTotals});

  final Map<String, double> categoryTotals;

  @override
  State<StatefulWidget> createState() => _PieChartWidget();
}

class _PieChartWidget extends State<PieChartWidget> {
  int touchedIndex = -1;
  List<Color> colors = [Color(0xFFa9b665), Color(0xFF7daea3),Color(0xFFea6962),Color(0xFFd8a657),Color(0xFFe78a4e)];

  Map<String, double> getPercentages(Map<String, double> categoryTotals) {
    double total = 0;
    if(categoryTotals.isNotEmpty) total = categoryTotals.values.reduce((value, element) => value + element);
      
    Map<String, double> percentages = {};
    for(var entry in widget.categoryTotals.entries) {
      percentages[entry.key] = entry.value / total * 100;
    }
    return percentages;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: PieChart(
              PieChartData(
                pieTouchData: pieTouchData,
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: showingSections(),
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(10), child: showItemList()),
      ],
    );
  }

  Column showItemList() {
    List<Widget> list = [];
    for (var entry in widget.categoryTotals.entries) {
      Indicator indicator = Indicator(
        color:
            colors[widget.categoryTotals.keys.toList().indexOf(
                  entry.key,
                ) %
                colors.length],
        text: entry.key,
        isSquare: true,
      );
      SizedBox sizedBox = SizedBox(height: 4);
      list.add(indicator);
      list.add(sizedBox);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  PieTouchData get pieTouchData => PieTouchData(
    enabled: false,
    touchCallback: (FlTouchEvent event, pieTouchResponse) {
      setState(() {
        if (!event.isInterestedForInteractions ||
            pieTouchResponse == null ||
            pieTouchResponse.touchedSection == null) {
          touchedIndex = -1;
          return;
        }
        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
      });
    },
  );

  List<PieChartSectionData> showingSections() {
    final Map<String, double> percentages = getPercentages(widget.categoryTotals);
    return widget.categoryTotals.entries.map((entry) {
      final isTouched =
          widget.categoryTotals.keys.toList().indexOf(entry.key) ==
          touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 120.0 : 110.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        value: percentages[entry.key],
        title: isTouched ? '${percentages[entry.key]!.toStringAsFixed(1)}%' : entry.value.toStringAsFixed(1),
        color:
            colors[widget.categoryTotals.keys.toList().indexOf(
                  entry.key,
                ) %
                colors.length],
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }
}
