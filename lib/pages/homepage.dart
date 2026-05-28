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

class Destination {
  const Destination(this.label, this.icon, this.selectedIcon, this.destPage,
      {this.drawer = false});

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final Widget? destPage;
  final bool? drawer;
}

class _HomepageState extends State<Homepage> {
  int currentPageIndex = 1;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState!.closeDrawer();
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      if (selectedScreen == 0) {
        openDrawer();
      } else {
        currentPageIndex = selectedScreen;
        closeDrawer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Destinations for the NavigationRail and NavigationDrawer
    List<Destination> destinations = <Destination>[
      const Destination(
          'Drawer', Icon(Icons.menu_outlined), Icon(Icons.menu), null,
          drawer: true),
      Destination(localizations.categoryLists, const Icon(Icons.list_outlined),
          const Icon(Icons.list), const ListPage()),
      Destination(localizations.categoryCounters, Icon(Icons.timer_outlined),
          Icon(Icons.timer), TimeCounterPage()),
      Destination(localizations.categorySettings, Icon(Icons.settings_outlined),
          Icon(Icons.settings), SettingsPage()),
    ];

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: NavigationRail(
                minWidth: 50,
                destinations: destinations.take(destinations.length - 1).map((
                  Destination destination,
                ) {
                  return NavigationRailDestination(
                    label: Text(destination.label),
                    icon: destination.icon,
                    selectedIcon: destination.selectedIcon,
                    padding: destination.drawer == true
                        ? const EdgeInsets.only(bottom: 20)
                        : null,
                  );
                }).toList(),
                selectedIndex: currentPageIndex < destinations.length - 1
                    ? currentPageIndex
                    : null,
                useIndicator: true,
                onDestinationSelected: (int index) {
                  handleScreenChanged(index);
                },
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: <Widget>[
                // Pages where the Navigation items lead to
                ListPage(),
                TimeCounterPage(),
                SettingsPage(),
              ][currentPageIndex - 1],
            ),
          ],
        ),
      ),
      drawer: NavigationDrawer(
        onDestinationSelected: (int index) => handleScreenChanged(index + 1),
        selectedIndex: currentPageIndex - 1,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'DailyApp',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 24),
              ),
              Expanded(
                child: Container(),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                tooltip: localizations.categorySettings,
                onPressed: () => handleScreenChanged(destinations.length - 1),
              ),
            ]),
          ),
          ...destinations
              .skip(1)
              .take(destinations.length - 2)
              .map((Destination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          }),
        ],
      ),
    );
  }
}
