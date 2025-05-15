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
  int touchedIndex = 1;

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
            Colors.primaries[widget.categoryTotals.keys.toList().indexOf(
                  entry.key,
                ) %
                Colors.primaries.length],
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
    return widget.categoryTotals.entries.map((entry) {
      final isTouched =
          widget.categoryTotals.keys.toList().indexOf(entry.key) ==
          touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 120.0 : 110.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        value: entry.value,
        title: isTouched ? entry.value.toString() : entry.key,
        color:
            Colors.primaries[widget.categoryTotals.keys.toList().indexOf(
                  entry.key,
                ) %
                Colors.primaries.length],
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
