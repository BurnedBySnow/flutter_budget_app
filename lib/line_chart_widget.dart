import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget{

  LineChartWidget();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 1.23,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 37,
              ),
              const Text(
                'Monthly Sales',
              )
            ],
          )
        ],
      ),
  );
  }
}
