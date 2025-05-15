import 'package:flutter/material.dart';
import 'package:flutter_budget_app/database_helper.dart';
import 'package:flutter_budget_app/gruvbox_colors.dart';
import 'package:flutter_budget_app/line_chart_widget.dart';
import 'package:flutter_budget_app/pie_chart.dart';
import 'package:flutter_budget_app/transaction.dart';
import 'package:intl/intl.dart';

class GraphScreen extends StatefulWidget {
  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Transaction> _transactions = [];
  Map<String, double> _categoryTotals = {};
  Map<String, double> _monthlyTotals = {};
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, 1, 1),
    end: DateTime(DateTime.now().year, 12, 31),
  );

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    List<Map<String, dynamic>> rows = await _dbHelper.queryAll();
    List<Transaction> transactions =
        rows.map((row) => Transaction.fromMap(row)).toList();
    setState(() {
      _transactions = transactions;
      _calculateCategoryTotals();
      _calculateMonthlyTotals();
    });
  }

  void _calculateCategoryTotals() {
    _categoryTotals.clear();
    DateTime now = DateTime.now();
    List<Transaction> monthlyTransactions =
        _transactions.where((t) {
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.type == 'Expense';
        }).toList();

    for (var transaction in monthlyTransactions) {
      if (_categoryTotals.containsKey(transaction.category)) {
        _categoryTotals[transaction.category] =
            _categoryTotals[transaction.category]! + transaction.amount;
      } else {
        _categoryTotals[transaction.category] = transaction.amount;
      }
    }
  }

  void _calculateMonthlyTotals() {
    _monthlyTotals.clear();

    List<String> allMonths = [];
    DateTime current = DateTime(
      _selectedDateRange.start.year,
      _selectedDateRange.start.month,
      1,
    );
    while (current.isBefore(_selectedDateRange.end) ||
        current.isAtSameMomentAs(_selectedDateRange.end)) {
      allMonths.add(DateFormat('yyyy-MM').format(current));
      current = DateTime(current.year, current.month + 1, 1);
    }

    for (String month in allMonths) {
      _monthlyTotals[month] = 0.0;
    }

    for (var transaction in _transactions) {
      if (transaction.date.isAfter(
            _selectedDateRange.start.subtract(Duration(days: 1)),
          ) &&
          transaction.date.isBefore(
            _selectedDateRange.end.add(Duration(days: 1)),
          ) &&
          transaction.type == 'Expense') {
        String monthKey = DateFormat('yyyy-MM').format(transaction.date);
        if (_monthlyTotals.containsKey(monthKey)) {
          _monthlyTotals[monthKey] =
              _monthlyTotals[monthKey]! + transaction.amount;
        }
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(DateTime.now().year - 5, 1, 1),
      lastDate: DateTime(DateTime.now().year + 5, 12, 31),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(colorScheme: gruvboxColorScheme),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _calculateMonthlyTotals();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return Column(
        children: <Widget>[
          Text(
            DateFormat('MMMM').format(DateTime.now()),
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Card(
              margin: EdgeInsets.all(15),
              color: Color(0xFF32302f),
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: PieChartWidget(categoryTotals: _categoryTotals),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10,),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDateRange(context),
              ),
              Text(
                '${DateFormat.yMMMd().format(_selectedDateRange.start)}  -  ${DateFormat.yMMMd().format(_selectedDateRange.end)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: Card(
              margin: EdgeInsets.all(15),
              color: Color(0xFF32302f),
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: LineChartWidget(monthlyTotals: _monthlyTotals),
              ),
            ),
          ),
        ],
    );
  }
}
