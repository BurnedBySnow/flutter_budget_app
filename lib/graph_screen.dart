import 'package:flutter/material.dart';
import 'package:flutter_budget_app/bar_chart_widget.dart';
import 'package:flutter_budget_app/database_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Column(
        children: <Widget>[
          Text(DateFormat('MMMM').format(DateTime.now())),
          Expanded(
            child: Card(
              margin: EdgeInsets.all(15),
              color: Color(0xFF32302f),
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: BarChartWidget(categoryTotals: _categoryTotals),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
