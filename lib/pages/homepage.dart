import 'package:DailyApp/generated/l10n/app_localizations.dart';
import 'package:DailyApp/pages/modules/listpage.dart';
import 'package:DailyApp/pages/modules/timecounterpage.dart';
import 'package:DailyApp/pages/settingspage.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: localizations.categoryLists,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.timer_outlined),
            icon: const Icon(Icons.timer),
            label: localizations.categoryCounters,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.settings_outlined),
            icon: const Icon(Icons.settings),
            label: localizations.categorySettings,
          ),
        ],
      ),
      appBar: AppBar(),
      body: <Widget>[
        ListPage(),

        TimeCounterPage(),

        SettingsPage(),
      ][currentPageIndex],
    );
  }
}
