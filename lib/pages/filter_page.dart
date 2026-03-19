import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

enum FilterPeriod { week, month, all }

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<Expense> _all = [];
  List<Expense> _filtered = [];
  FilterPeriod _period = FilterPeriod.week;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    _all = await DatabaseHelper.instance.readAllExpenses();
    _applyFilter();
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    final now = DateTime.now();
    setState(() {
      switch (_period) {
        case FilterPeriod.week:
          final cutoff = now.subtract(const Duration(days: 7));
          _filtered =
              _all.where((e) => e.date.isAfter(cutoff)).toList();
          break;
        case FilterPeriod.month:
          final cutoff = now.subtract(const Duration(days: 30));
          _filtered =
              _all.where((e) => e.date.isAfter(cutoff)).toList();
          break;
        case FilterPeriod.all:
          _filtered = List.from(_all);
          break;
      }
    });
  }

  String get _periodLabel {
    switch (_period) {
      case FilterPeriod.week:
        return 'Last 7 Days';
      case FilterPeriod.month:
        return 'Last 30 Days';
      case FilterPeriod.all:
        return 'All Time';
    }
  }

  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (final e in _filtered) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total =
        _filtered.fold<double>(0, (sum, e) => sum + e.amount);
    final catTotals = _categoryTotals;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadExpenses,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- Filter Chips ----------
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.filter_alt, color: cs.primary),
                            const SizedBox(width: 8),
                            Text('Filter Expenses',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 12),
                          SegmentedButton<FilterPeriod>(
                            segments: const [
                              ButtonSegment(
                                value: FilterPeriod.week,
                                label: Text('7 Days'),
                                icon: Icon(Icons.calendar_view_week),
                              ),
                              ButtonSegment(
                                value: FilterPeriod.month,
                                label: Text('30 Days'),
                                icon: Icon(Icons.calendar_month),
                              ),
                              ButtonSegment(
                                value: FilterPeriod.all,
                                label: Text('All Time'),
                                icon: Icon(Icons.all_inclusive),
                              ),
                            ],
                            selected: {_period},
                            onSelectionChanged: (Set<FilterPeriod> s) {
                              _period = s.first;
                              _applyFilter();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- Summary Cards ----------
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.receipt_long,
                          label: 'Transactions',
                          value: '${_filtered.length}',
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.currency_rupee,
                          label: 'Total Spent',
                          value: '₹${total.toStringAsFixed(0)}',
                          color: cs.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.trending_up,
                          label: 'Avg / Day',
                          value: _period == FilterPeriod.week
                              ? '₹${(total / 7).toStringAsFixed(0)}'
                              : _period == FilterPeriod.month
                                  ? '₹${(total / 30).toStringAsFixed(0)}'
                                  : '—',
                          color: cs.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.category,
                          label: 'Categories',
                          value: '${catTotals.length}',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---------- Category Breakdown ----------
                  if (catTotals.isNotEmpty) ...[
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category Breakdown – $_periodLabel',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ...catTotals.entries.map((entry) {
                              final pct = total > 0
                                  ? entry.value / total
                                  : 0.0;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(entry.key,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600)),
                                        Text(
                                          '₹${entry.value.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(1)}%)',
                                          style: TextStyle(
                                              color: cs.primary,
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 8,
                                        backgroundColor:
                                            cs.surfaceContainerHighest,
                                        valueColor:
                                            AlwaysStoppedAnimation<
                                                Color>(cs.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ---------- Transaction List ----------
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transactions – $_periodLabel',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (_filtered.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                  child: Text('No expenses in this period.',
                                      style: TextStyle(
                                          color: Colors.grey))),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final e = _filtered[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        cs.secondaryContainer,
                                    child: Text(
                                      e.category[0],
                                      style: TextStyle(
                                          color:
                                              cs.onSecondaryContainer,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(e.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    '${e.category} • ${DateFormat('dd MMM yyyy').format(e.date)}',
                                    style: TextStyle(
                                        color: cs.onSurfaceVariant),
                                  ),
                                  trailing: Text(
                                    '₹${e.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cs.primary,
                                      fontSize: 15,
                                    ),
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
            ),
          );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
