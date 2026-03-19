import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'pages/add_expense_page.dart';
import 'pages/filter_page.dart';
import 'pages/charts_page.dart';
import 'pages/settings_page.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: lightScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Counter that increments on every expense change to force child rebuilds
  int _refreshCounter = 0;

  void _onExpenseChanged() {
    setState(() {
      _refreshCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final pages = [
      AddExpensePage(
        key: ValueKey('home_$_refreshCounter'),
        onExpenseAdded: _onExpenseChanged,
      ),
      FilterPage(key: ValueKey('filter_$_refreshCounter')),
      ChartsPage(key: ValueKey('charts_$_refreshCounter')),
      const SettingsPage(),
    ];

    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.filter_list_outlined),
        selectedIcon: Icon(Icons.filter_list),
        label: 'Filter',
      ),
      NavigationDestination(
        icon: Icon(Icons.pie_chart_outline),
        selectedIcon: Icon(Icons.pie_chart),
        label: 'Charts',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    final pageTitles = [
      'Expense Tracker',
      'Filter Expenses',
      'Expense Charts',
      'Settings',
    ];

    final pageIcons = [
      Icons.account_balance_wallet,
      Icons.filter_list,
      Icons.pie_chart,
      Icons.settings,
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        elevation: 0,
        title: Row(
          children: [
            Icon(pageIcons[_currentIndex], color: cs.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              pageTitles[_currentIndex],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
                color: cs.primary,
              ),
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme(!isDark);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: destinations,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  @override
  void dispose() {
    DatabaseHelper.instance.close();
    super.dispose();
  }
}
