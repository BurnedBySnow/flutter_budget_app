import 'package:flutter/material.dart';
import 'package:flutter_budget_app/gruvbox_colors.dart';
import 'package:flutter_budget_app/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  AddTransactionScreen({this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Income';
  double _amount = 0.0;
  String _category = '';
  DateTime _date = DateTime.now();
  String? _recurrence;

  @override
  void initState() {
    super.initState();
    debugPrint((widget.transaction != null).toString());
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _amount = widget.transaction!.amount;
      _category = widget.transaction!.category;
      _date = widget.transaction!.date;
      _recurrence = widget.transaction!.recurrence ?? 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Update Transaction',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                items:
                    ['Income', 'Expense'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                decoration: InputDecoration(labelText: 'Type'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: widget.transaction != null ? _amount.toString() : null,
                decoration: InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onSaved: (value) {
                  _category = value!;
                },
              ),
              DropdownButtonFormField<String>(
                value: _recurrence,
                onChanged: (value) {
                  setState(() {
                    _recurrence = value;
                  });
                },
                items:
                    ['None', 'Daily', 'Weekly', 'Monthly'].map((recurrence) {
                      return DropdownMenuItem(
                        value: recurrence,
                        child: Text(recurrence),
                      );
                    }).toList(),
                decoration: InputDecoration(labelText: 'Recurrence'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    gruvboxColorScheme.secondary,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Transaction transaction = Transaction(
                      id: widget.transaction?.id,
                      type: _type,
                      amount: _amount,
                      category: _category,
                      date: _date,
                      recurrence: _recurrence == 'None' ? null : _recurrence,
                    );
                    Navigator.pop(context, transaction);
                  }
                },
                child: Text(
                  widget.transaction == null ? 'Add' : 'Update',
                  style: TextStyle(
                    color: gruvboxColorScheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
