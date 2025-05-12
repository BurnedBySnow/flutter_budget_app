import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_budget_app/add_transaction_screen.dart';
import 'package:flutter_budget_app/graph_screen.dart';
import 'package:flutter_budget_app/gruvbox_colors.dart';
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
  int _selectedIndex = 0;
  List<String> _destinations = ['Home', 'Graphs', 'Add'];

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
    });
  }

  void _addTransaction(Transaction transaction) async {
    await _dbHelper.insert(transaction.toMap());
    if (transaction.recurrence != null || transaction.recurrence != 'None') {
      _createRecurringTransaction(transaction);
    }
    _loadTransactions();
  }

  void _createRecurringTransaction(Transaction transaction) async {
    DateTime nextDate = transaction.date;
    switch (transaction.recurrence) {
      case 'Daily':
        nextDate = nextDate.add(Duration(days: 1));
      case 'Weekly':
        nextDate = nextDate.add(Duration(days: 7));
      case 'Monthly':
        nextDate = nextDate.add(Duration(days: 30));
      default:
        return;
    }

    Transaction recurringTransaction = Transaction(
      type: transaction.type,
      amount: transaction.amount,
      category: transaction.category,
      date: nextDate,
      recurrence: transaction.recurrence,
    );

    await _dbHelper.insert(recurringTransaction.toMap());
    if (nextDate.isBefore(DateTime.now().add(Duration(days: 365)))) {
      _createRecurringTransaction(recurringTransaction);
    }
  }

  void _removeTransaction(Transaction transaction) async {
    await _dbHelper.deleteTransaction(transaction.id!);
    if (transaction.recurrence != null) {
      _removeRecurringTransaction(transaction);
    }
    _loadTransactions();
  }

  void _removeRecurringTransaction(Transaction transaction) async {
    List<Transaction> allTransactions =
        _transactions
            .where(
              (t) =>
                  t.type == transaction.type &&
                  t.amount == transaction.amount &&
                  t.category == transaction.category &&
                  t.recurrence == transaction.recurrence &&
                  t.date.isAfter(transaction.date),
            )
            .toList();

    for (var t in allTransactions) {
      await _dbHelper.deleteTransaction(t.id!);
    }
  }

  void _updateTransaction(Transaction transaction) async {
    final updatedTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );

    if (updatedTransaction != null) {
      await _dbHelper.updateTransaction(updatedTransaction);
      if (transaction.recurrence != null) {
        _updateRecurringTransactions(transaction, updatedTransaction);
      }
      _loadTransactions();
    }
  }

  void _updateRecurringTransactions(Transaction oldTransaction, Transaction newTransaction) async {
    List<Transaction> allTransactions = _transactions.where((t) =>
        t.type == oldTransaction.type &&
        t.amount == oldTransaction.amount &&
        t.category == oldTransaction.category &&
        t.recurrence == oldTransaction.recurrence &&
        t.date.isAfter(oldTransaction.date)
    ).toList();

    for (var t in allTransactions) {
      Transaction updatedTransaction = Transaction(
        id: t.id,
        type: newTransaction.type,
        amount: newTransaction.amount,
        category: newTransaction.category,
        date: t.date,
        recurrence: newTransaction.recurrence,
      );
      await _dbHelper.updateTransaction(updatedTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Color(0xFF32302f)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _destinations[_selectedIndex],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFF3c3836))),
          boxShadow: [BoxShadow(color: Colors.white)],
        ),
        child: NavigationBar(
          backgroundColor: Color(0xFF32302f),
          onDestinationSelected: (int index) async {
            if (index == 2) {
              final transaction = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTransactionScreen()),
              );
              if (transaction != null) {
                _addTransaction(transaction);
              }
              setState(() {
                _selectedIndex = 0;
              });
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          indicatorColor: colorScheme.secondary,
          selectedIndex: _selectedIndex,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home),
              label: _destinations[0],
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bar_chart),
              icon: Icon(Icons.bar_chart),
              label: _destinations[1],
            ),
            NavigationDestination(icon: Icon(Icons.add), label: "Add"),
          ],
        ),
      ),
      body:
          <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthlyOverview(),
                Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
                  child: Text(
                    "Recent",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(_transactions[index].id.toString()),
                        background: Container(
                          color: gruvboxColorScheme.error,
                          alignment: Alignment.centerLeft,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Delete',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color(0xFF32302f),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          color: gruvboxColorScheme.secondary,
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Edit',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color(0xFF32302f),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        confirmDismiss: (DismissDirection direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Color(0xFF32302f),
                                  title: const Text('Delete'),
                                  content: const Text(
                                    'Are you sure you want to delete this transaction ?',
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Yes'),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('No'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          if (direction == DismissDirection.endToStart) {
                            _updateTransaction(_transactions[index]);
                            return false;
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          _removeTransaction(_transactions[index]);
                        },
                        child: ListTile(
                          title: Text(_transactions[index].category),
                          subtitle: Text(
                            '${_transactions[index].amount}',
                            style: TextStyle(
                              color:
                                  _transactions[index].type == 'Expense'
                                      ? gruvboxColorScheme.error
                                      : gruvboxColorScheme.secondary,
                            ),
                          ),
                          trailing: Text(
                            DateFormat(
                              'MMMM d',
                            ).format(_transactions[index].date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder:
                        (BuildContext context, int index) =>
                            const Divider(color: Color(0xFF32302f), height: 2),
                  ),
                ),
              ],
            ),
            GraphScreen(),
          ][_selectedIndex],
    );
  }

  Widget _buildMonthlyOverview() {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM yyyy').format(now);
    List<Transaction> monthlyTransactions =
        _transactions.where((t) {
          return t.date.year == now.year && t.date.month == now.month;
        }).toList();

    double totalIncome = monthlyTransactions
        .where((t) => t.type == 'Income')
        .fold(0, (sum, t) => sum + t.amount);
    double totalExpense = monthlyTransactions
        .where((t) => t.type == 'Expense')
        .fold(0, (sum, t) => sum + t.amount);
    double net = totalIncome - totalExpense;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Color(0xFF32302f),
        margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Monthly Overview for $currentMonth',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Income: $totalIncome',
                style: TextStyle(
                  fontSize: 16.0,
                  color: gruvboxColorScheme.secondary,
                ),
              ),
              Text(
                'Expense: $totalExpense',
                style: TextStyle(
                  fontSize: 16.0,
                  color: gruvboxColorScheme.error,
                ),
              ),
              Text(
                'Net: $net',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
