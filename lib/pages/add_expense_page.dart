import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class AddExpensePage extends StatefulWidget {
  final VoidCallback onExpenseAdded;
  const AddExpensePage({super.key, required this.onExpenseAdded});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = expenseCategories.first;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  Future _refreshExpenses() async {
    setState(() => _isLoading = true);
    _expenses = await DatabaseHelper.instance.readAllExpenses();
    setState(() => _isLoading = false);
  }

  void _addExpense() async {
    final title = _titleController.text;
    final amountText = _amountController.text;

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount')),
      );
      return;
    }

    final newExpense = Expense(
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: _selectedCategory,
    );

    await DatabaseHelper.instance.create(newExpense);

    _titleController.clear();
    _amountController.clear();
    setState(() {
      _selectedCategory = expenseCategories.first;
    });

    FocusScope.of(context).unfocus();
    _refreshExpenses();
    widget.onExpenseAdded();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _editExpense(Expense expense) {
    final editTitleController = TextEditingController(text: expense.title);
    final editAmountController =
        TextEditingController(text: expense.amount.toString());
    String editCategory = expense.category;

    if (!expenseCategories.contains(editCategory)) {
      editCategory = expenseCategories.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editTitleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: editAmountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: editCategory,
                    decoration:
                        const InputDecoration(labelText: 'Category'),
                    items: expenseCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        editCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newAmount =
                      double.tryParse(editAmountController.text);
                  if (editTitleController.text.isNotEmpty &&
                      newAmount != null &&
                      newAmount > 0) {
                    final updatedExpense = Expense(
                      id: expense.id,
                      title: editTitleController.text,
                      amount: newAmount,
                      date: expense.date,
                      category: editCategory,
                    );
                    await DatabaseHelper.instance.update(updatedExpense);
                    if (context.mounted) Navigator.pop(context);
                    _refreshExpenses();
                    widget.onExpenseAdded();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter valid data')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Delete "${expense.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && expense.id != null) {
      await DatabaseHelper.instance.delete(expense.id!);
      _refreshExpenses();
      widget.onExpenseAdded();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalExpense = _expenses.fold<double>(
        0.0, (prev, e) => prev + e.amount);
    final cs = Theme.of(context).colorScheme;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------- Add Form ----------
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.add_circle_outline, color: cs.primary),
                          const SizedBox(width: 8),
                          Text('Add New Expense',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Expense Title',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _amountController,
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category),
                                ),
                                items:
                                    expenseCategories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _addExpense,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Expense'),
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ---------- Expense List ----------
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('All Expenses',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Total: ₹${totalExpense.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ]),
                        const SizedBox(height: 12),
                        if (_expenses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long,
                                      size: 48,
                                      color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('No expenses recorded yet.',
                                      style:
                                          TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: _expenses.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final expense = _expenses[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: cs.secondaryContainer,
                                  child: Text(
                                    expense.category[0],
                                    style: TextStyle(
                                        color: cs.onSecondaryContainer,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(expense.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                                  style:
                                      TextStyle(color: cs.onSurfaceVariant),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₹${expense.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: cs.primary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert,
                                          color: cs.onSurfaceVariant),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editExpense(expense);
                                        } else if (value == 'delete') {
                                          _deleteExpense(expense);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(children: [
                                            Icon(Icons.edit,
                                                color: Colors.blue,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ]),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [
                                            Icon(Icons.delete,
                                                color: Colors.red,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
