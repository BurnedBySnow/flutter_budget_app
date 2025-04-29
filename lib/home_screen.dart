import 'package:flutter/material.dart';
import 'package:flutter_budget_app/add_transaction_screen.dart';
import 'package:flutter_budget_app/transaction.dart';
import 'package:flutter_budget_app/database_helper.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    List<Map<String, dynamic>> rows = await _dbHelper.queryAll();
    List<Transaction> transactions = rows.map((row) => Transaction.fromMap(row)).toList();
    setState(() {
      _transactions = transactions;
    });
  }

  void _addTransaction(Transaction transaction) async {
    await _dbHelper.insert(transaction.toMap());
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget App'),
        backgroundColor: colorScheme.secondary,
      ),
      body: Column(
        children: [
          _buildMonthlyOverview(),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_transactions[index].category),
                  subtitle: Text(
                    '${_transactions[index].amount}',
                    style: TextStyle(color: _transactions[index].type == 'Expense' ? Colors.red : Colors.green),),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final transaction = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
          if (transaction != null) {
            _addTransaction(transaction);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM yyyy').format(now);
    List<Transaction> monthlyTransactions = _transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    double totalIncome = monthlyTransactions.where((t) => t.type == 'Income').fold(0, (sum, t) => sum + t.amount);
    double totalExpense = monthlyTransactions.where((t) => t.type == 'Expense').fold(0, (sum, t) => sum + t.amount);
    double net = totalIncome - totalExpense;

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Monthly Overview for $currentMonth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Income: $totalIncome'),
            Text('Expense: $totalExpense'),
            Text('Net: $net', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

