import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'pages/homepage.dart';
import 'utils/preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:DailyApp/generated/l10n/app_localizations.dart';

void main() async {
  // ignore: prefer_const_constructors
  runApp(Phoenix(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: Preferences.getPrefString('language'),
        builder: (context, languageSnapshot) {
          final currentLanguage = languageSnapshot.data ?? '';

          return FutureBuilder<bool>(
            future: Preferences.getPrefBool('darkmode'),
            builder: (context, themeModeSnapshot) {
              final currentThemeMode =
                  themeModeSnapshot.data ?? ThemeMode.system;

              return MaterialApp(
                title: 'DailyApp',
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', ''), // English
                  Locale('de', ''), // German
                ],
                locale: currentLanguage != ""
                    ? Locale(currentLanguage, '')
                    : PlatformDispatcher.instance.locale,
                home: const Homepage(),
                themeMode:
                    currentThemeMode == true ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData.light(
                  useMaterial3: true,
                ),
                darkTheme: ThemeData.dark(
                  useMaterial3: true,
                ),
              );
            },
          );
        });
  }
}
