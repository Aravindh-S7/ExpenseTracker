class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      description: map['description'] as String?,
    );
  }
}

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Utilities',
  'Entertainment',
  'Health',
  'Shopping',
  'Other',
];
