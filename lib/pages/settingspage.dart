import 'dart:ui';
import 'package:DailyApp/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguageValue = '';
  bool selectedDarkmodeValue = true;
  bool selectedDynamicThemeValue = false;
  bool selectedAskListDeletionValue = true;
  bool selectedAskListEntryDeletionValue = true;
  bool selectedAskTimeDeletionValue = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    selectedLanguageValue = PlatformDispatcher.instance.locale.languageCode;

    dynamic prefs = await Future.wait([
      Preferences.getPrefString('language'),
      Preferences.getPrefBool('darkmode'),
      Preferences.getPrefBool('dynamic_theme'),
      Preferences.getPrefBool('list-deletion'),
      Preferences.getPrefBool('list-entry-deletion'),
      Preferences.getPrefBool('time-deletion'),
    ]);

    if (!mounted) return;

    setState(() {
      selectedLanguageValue = prefs[0];
      selectedDarkmodeValue = prefs[1];
      selectedDynamicThemeValue = prefs[2];
      selectedAskListDeletionValue = prefs[3];
      selectedAskListEntryDeletionValue = prefs[4];
      selectedAskTimeDeletionValue = prefs[5];
    });
  }

  Future<void> saveSettings() async {
    await Preferences.setPrefString('language', selectedLanguageValue);
    await Preferences.setPrefBool('darkmode', selectedDarkmodeValue);
    await Preferences.setPrefBool('dynamic_theme', selectedDynamicThemeValue);
    await Preferences.setPrefBool(
        'list-deletion', selectedAskListDeletionValue);
    await Preferences.setPrefBool(
        'list-entry-deletion', selectedAskListEntryDeletionValue);
    await Preferences.setPrefBool(
        'time-deletion', selectedAskTimeDeletionValue);

    if (!mounted) return;
    Phoenix.rebirth(context);
  }

  void setLanguage(String languageCode) {
    setState(() {
      selectedLanguageValue = languageCode;
    });
  }

  void toggleSwitchDarkmode() {
    setState(() {
      selectedDarkmodeValue = !selectedDarkmodeValue;
    });
  }

  void toggleSwitchDynamicTheme() {
    setState(() {
      selectedDynamicThemeValue = !selectedDynamicThemeValue;
    });
  }

  void toggleSwitchAskListDeletion() {
    setState(() {
      selectedAskListDeletionValue = !selectedAskListDeletionValue;
    });
  }

  void toggleSwitchAskListEntryDeletion() {
    setState(() {
      selectedAskListEntryDeletionValue = !selectedAskListEntryDeletionValue;
    });
  }

  void toggleSwitchAskTimeDeletion() {
    setState(() {
      selectedAskTimeDeletionValue = !selectedAskTimeDeletionValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveSettings();
        },
        label: Text(localizations.generalFabTitle),
        icon: Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 55),
              Row(children: [
                const SizedBox(width: 7),
                Text(localizations.categorySettings,
                    style: const TextStyle(fontSize: 50)),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                const SizedBox(width: 7),
                Text(localizations.settingsTitleGeneral,
                    style: const TextStyle(fontSize: 25)),
              ]),
              Card(
                  child: ListTile(
                title: Text(localizations.settingsRepoTitle),
                subtitle: Text(localizations.settingsRepoSubtitle),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  _launchURL(
                      'https://github.com/OptixWolf/DailyApp/releases/latest');
                },
              )),
              Card(
                  child: ListTile(
                title: const Text('Language'),
                subtitle: const Text('Change the app language'),
                trailing: DropdownButton<Locale>(
                  value: selectedLanguageValue != ""
                      ? Locale(selectedLanguageValue, '')
                      : Locale(PlatformDispatcher.instance.locale.languageCode),
                  items: AppLocalizations.supportedLocales.map((locale) {
                    final label = switch (locale.languageCode) {
                      'de' => 'Deutsch',
                      'en' => 'English',
                      _ => locale.languageCode.toUpperCase(),
                    };

                    return DropdownMenuItem(
                      value: locale,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (Locale? newValue) {
                    if (newValue != null) {
                      setLanguage(newValue.languageCode);
                    }
                  },
                ),
              )),
              Card(
                  child: ListTile(
                title: Text(localizations.settingsDarkmodeTitle),
                subtitle: Text(localizations.settingsDarkmodeSubtitle),
                trailing: Switch(
                  value: selectedDarkmodeValue,
                  onChanged: (value) {
                    toggleSwitchDarkmode();
                  },
                ),
                onTap: () {
                  toggleSwitchDarkmode();
                },
              )),
              Card(
                  child: ListTile(
                title: Text(localizations.settingsDynamicThemeTitle),
                subtitle: Text(localizations.settingsDynamicThemeSubtitle),
                trailing: Switch(
                  value: selectedDynamicThemeValue,
                  onChanged: (value) {
                    toggleSwitchDynamicTheme();
                  },
                ),
                onTap: () {
                  toggleSwitchDynamicTheme();
                },
              )),
              Card(
                  child: ExpansionTile(
                title: Text(localizations.settingsConfirmationsForDeletion),
                children: [
                  Card(
                      child: ListTile(
                    title: Text(
                        localizations.settingsConfirmationListDeletionTitle),
                    subtitle: Text(
                        localizations.settingsConfirmationListDeletionSubtitle),
                    trailing: Switch(
                      value: selectedAskListDeletionValue,
                      onChanged: (value) {
                        toggleSwitchAskListDeletion();
                      },
                    ),
                    onTap: () {
                      toggleSwitchAskListDeletion();
                    },
                  )),
                  Card(
                      child: ListTile(
                    title: Text(localizations
                        .settingsConfirmationListEntryDeletionTitle),
                    subtitle: Text(localizations
                        .settingsConfirmationListEntryDeletionSubtitle),
                    trailing: Switch(
                      value: selectedAskListEntryDeletionValue,
                      onChanged: (value) {
                        toggleSwitchAskListEntryDeletion();
                      },
                    ),
                    onTap: () {
                      toggleSwitchAskListEntryDeletion();
                    },
                  )),
                  Card(
                      child: ListTile(
                    title: Text(
                        localizations.settingsConfirmationCounterDeletionTitle),
                    subtitle: Text(localizations
                        .settingsConfirmationCounterDeletionSubtitle),
                    trailing: Switch(
                      value: selectedAskTimeDeletionValue,
                      onChanged: (value) {
                        toggleSwitchAskTimeDeletion();
                      },
                    ),
                    onTap: () {
                      toggleSwitchAskTimeDeletion();
                    },
                  )),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final localizations = AppLocalizations.of(context)!;
    final Uri finalUrl = Uri.parse(url);
    if (!await launchUrl(finalUrl)) {
      throw Exception(localizations.launchUrlFailed(finalUrl.toString()));
    }
  }
}
