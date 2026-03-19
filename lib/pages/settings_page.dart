import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --------------- Appearance -------------------
          _SectionHeader(icon: Icons.palette, label: 'Appearance', cs: cs),
          const SizedBox(height: 8),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      key: ValueKey(themeProvider.isDarkMode),
                      color: cs.primary,
                    ),
                  ),
                  title: const Text('Dark Mode',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Dark theme active'
                        : 'Light theme active',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --------------- Database Info -------------------
          _SectionHeader(icon: Icons.storage, label: 'Database', cs: cs),
          const SizedBox(height: 8),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.verified,
                          color: Colors.teal, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('sqflite',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal)),
                          Text('Active Database Engine',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const _DbInfoRow(
                    icon: Icons.info_outline,
                    label: 'Package',
                    value: 'sqflite ^2.3.0',
                  ),
                  const _DbInfoRow(
                    icon: Icons.layers,
                    label: 'Engine',
                    value: 'SQLite (local, on-device)',
                  ),
                  const _DbInfoRow(
                    icon: Icons.phone_android,
                    label: 'Platform',
                    value: 'Android (persistent SQLite file)',
                  ),
                  const _DbInfoRow(
                    icon: Icons.table_rows,
                    label: 'Table',
                    value: '"expenses" – id, title, amount, date, category',
                  ),
                  const _DbInfoRow(
                    icon: Icons.lock,
                    label: 'Scope',
                    value: 'Local-only, no network required',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.teal.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.teal, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This app uses sqflite as its database engine. All expense data is stored locally on-device using SQLite.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --------------- App Flowchart -------------------
          _SectionHeader(
              icon: Icons.account_tree, label: 'App Flowchart', cs: cs),
          const SizedBox(height: 8),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'End-to-end data flow of the Expense Tracker',
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  _FlowNode(
                    icon: Icons.person,
                    label: 'User',
                    color: cs.primary,
                    desc: 'Opens the app',
                  ),
                  const _Arrow(),
                  _FlowNode(
                    icon: Icons.phone_android,
                    label: 'App Launch',
                    color: cs.secondary,
                    desc: 'main() → runApp()',
                  ),
                  const _Arrow(),
                  _FlowNode(
                    icon: Icons.storage,
                    label: 'sqflite Database',
                    color: Colors.teal,
                    desc: 'SQLite via sqflite – persistent local storage',
                  ),
                  const _Arrow(),
                  _FlowNode(
                    icon: Icons.build,
                    label: 'DatabaseHelper',
                    color: cs.tertiary,
                    desc: 'Singleton: create / read / update / delete',
                  ),
                  const _Arrow(),
                  _FlowNode(
                    icon: Icons.table_chart,
                    label: 'Expense Model',
                    color: Colors.purple,
                    desc: 'id, title, amount, date, category',
                  ),
                  const _Arrow(),
                  // Decision
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      border: Border.all(color: cs.tertiary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.device_hub,
                            color: cs.tertiary, size: 18),
                        const SizedBox(width: 6),
                        Text('User Action?',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.onTertiaryContainer)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: _FlowNode(
                        icon: Icons.edit_note,
                        label: 'Mutation',
                        color: Colors.blue,
                        desc: 'Add / Edit / Delete\n→ Write to DB',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FlowNode(
                        icon: Icons.search,
                        label: 'Query',
                        color: Colors.green,
                        desc: 'View / Filter\n→ Read from DB',
                      ),
                    ),
                  ]),
                  const _Arrow(),
                  _FlowNode(
                    icon: Icons.widgets,
                    label: 'UI Rebuild',
                    color: cs.primary,
                    desc: 'setState() → widget tree rebuilds with fresh data',
                  ),
                  const _Arrow(),
                  Row(children: [
                    Expanded(
                      child: _FlowNode(
                        icon: Icons.list_alt,
                        label: 'Home / Filter',
                        color: Colors.teal,
                        desc: 'Add & list\n7d / 30d / All',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FlowNode(
                        icon: Icons.pie_chart,
                        label: 'Charts',
                        color: Colors.indigo,
                        desc: 'Pie & bar chart\nby category',
                      ),
                    ),
                  ]),
                  const _Arrow(),
                  _FlowNode(
                    icon: Icons.check_circle,
                    label: 'User Sees Updated UI',
                    color: Colors.green,
                    desc: 'Loop back to "User" on next action',
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(spacing: 14, runSpacing: 6, children: [
                    _LegendDot(color: cs.primary, label: 'User / UI'),
                    const _LegendDot(
                        color: Colors.teal, label: 'sqflite DB'),
                    _LegendDot(
                        color: cs.tertiary, label: 'DatabaseHelper'),
                    const _LegendDot(
                        color: Colors.purple, label: 'Data Model'),
                    const _LegendDot(
                        color: Colors.blue, label: 'Write'),
                    const _LegendDot(
                        color: Colors.green, label: 'Read'),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --------------- About -------------------
          _SectionHeader(icon: Icons.info, label: 'About', cs: cs),
          const SizedBox(height: 8),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.teal, size: 32),
                    SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expense Tracker',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('Version 1.0.0',
                              style: TextStyle(fontSize: 12)),
                        ]),
                  ]),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'An expense tracker built with Flutter & sqflite. '
                    'Manages finances locally using SQLite. Supports '
                    'filtering by date range, category charts, and '
                    'Material 3 theming with dark mode.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---- Reusable helper widgets ----

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const _SectionHeader(
      {required this.icon, required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: cs.primary),
      const SizedBox(width: 6),
      Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: cs.primary)),
    ]);
  }
}

class _DbInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DbInfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _FlowNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String desc;
  const _FlowNode(
      {required this.icon,
      required this.label,
      required this.color,
      required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14)),
              Text(desc,
                  style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Icon(Icons.keyboard_arrow_down,
          size: 28, color: Theme.of(context).colorScheme.outline),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }
}
