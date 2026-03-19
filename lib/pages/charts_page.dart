import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

/// Charts page showing a pie chart and bar chart of expenses by category.
class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  static const List<Color> _categoryColors = [
    Colors.teal,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    _expenses = await DatabaseHelper.instance.readAllExpenses();
    setState(() => _isLoading = false);
  }

  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  double get _totalAmount =>
      _expenses.fold<double>(0, (sum, e) => sum + e.amount);

  Color _colorForIndex(int index) =>
      _categoryColors[index % _categoryColors.length];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catTotals = _categoryTotals;
    final total = _totalAmount;
    final entries = catTotals.entries.toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: cs.outline),
            const SizedBox(height: 12),
            Text('No expenses to chart yet.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -------- Pie Chart --------
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(children: [
                    Icon(Icons.pie_chart, color: cs.primary),
                    const SizedBox(width: 8),
                    Text('Spending by Category',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(enabled: false),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: List.generate(entries.length, (i) {
                          return PieChartSectionData(
                            color: _colorForIndex(i),
                            value: entries[i].value,
                            title: '',
                            radius: 55,
                            showTitle: false,
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend with percentages
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children:
                        List.generate(entries.length, (i) {
                      final pct = total > 0
                          ? (entries[i].value / total * 100)
                          : 0.0;
                      return Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _colorForIndex(i),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                            '${entries[i].key} (${pct.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 12)),
                      ]);
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // -------- Bar Chart --------
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.bar_chart, color: cs.primary),
                    const SizedBox(width: 8),
                    Text('Category Comparison',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: entries
                                .map((e) => e.value)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem:
                                (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${entries[group.x.toInt()].key}\n₹${rod.toY.toStringAsFixed(0)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= entries.length) {
                                  return const SizedBox.shrink();
                                }
                                // Show first 3 chars of category
                                final label = entries[idx].key.length > 4
                                    ? entries[idx].key.substring(0, 4)
                                    : entries[idx].key;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(label,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                return Text('₹${value.toInt()}',
                                    style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval:
                              entries.map((e) => e.value).reduce(
                                          (a, b) => a > b ? a : b) /
                                      4,
                        ),
                        barGroups:
                            List.generate(entries.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: entries[i].value,
                                color: _colorForIndex(i),
                                width: 22,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // -------- Category Summary Table --------
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Summary',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...List.generate(entries.length, (i) {
                    final pct =
                        total > 0 ? entries[i].value / total : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _colorForIndex(i),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(entries[i].key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                              Text(
                                '₹${entries[i].value.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(1)}%)',
                                style: TextStyle(
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _colorForIndex(i)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('₹${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: cs.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
