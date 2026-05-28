// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get sTTSeperateWord => ' und ';

  @override
  String get categoryLists => 'Listen';

  @override
  String get categoryCounters => 'Zeitzähler';

  @override
  String get categorySettings => 'Einstellungen';

  @override
  String get generalFabTitle => 'Speichern';

  @override
  String get generalSwitchIndicators => 'Sortierindikatoren wechseln';

  @override
  String get generalDeleteAllEntries => 'Alle Einträge löschen';

  @override
  String get generalFieldMustNotBeEmpty => 'Feld darf nicht leer sein!';

  @override
  String get generalNoEntriesFound => 'Keine Einträge gefunden';

  @override
  String get listsNoListMessage => 'Keine Listen vorhanden';

  @override
  String get listsExampleName => 'Einkaufsliste';

  @override
  String get listsEditFieldText => 'Neuer Name für Liste';

  @override
  String get listsNameMustNotBeDuplicate =>
      'Name darf nicht doppelt vorkommen!';

  @override
  String get countersExampleName => 'Name';

  @override
  String get countersEditFieldText => 'Neuer Name für Zähler';

  @override
  String counterRunningFor(int days, int hours, int minutes, int seconds) {
    return 'Am laufen seit: ${days}d ${hours}h ${minutes}min ${seconds}s';
  }

  @override
  String get settingsTitleGeneral => 'Allgemeine Einstellungen';

  @override
  String get settingsRepoTitle => 'Quellcode (Extern)';

  @override
  String get settingsRepoSubtitle =>
      'Hier kommst du zum GitHub Repository vom Projekt';

  @override
  String get settingsDarkmodeTitle => 'Dunkler Modus';

  @override
  String get settingsDarkmodeSubtitle =>
      'Wenn aktiviert, benutzt die App das dunkle Design';

  @override
  String get settingsDynamicThemeTitle => 'Dynamisches Design';

  @override
  String get settingsDynamicThemeSubtitle =>
      'Wenn aktiviert, versucht es sich den Farben des Gerätes anzupassen';

  @override
  String get settingsConfirmationsForDeletion => 'Bestätigungen fürs löschen';

  @override
  String get settingsConfirmationListDeletionTitle =>
      'Bestätige das löschen von Listen';

  @override
  String get settingsConfirmationListDeletionSubtitle =>
      'Wenn deaktiviert, wirst du nicht mehr zum löschen einer Liste gefragt';

  @override
  String get settingsConfirmationListEntryDeletionTitle =>
      'Bestätige das löschen von Listeneinträgen';

  @override
  String get settingsConfirmationListEntryDeletionSubtitle =>
      'Wenn deaktiviert, wirst du nicht mehr zum löschen einer Listeneinträgen gefragt';

  @override
  String get settingsConfirmationCounterDeletionTitle =>
      'Bestätige das löschen von Zeitzählern';

  @override
  String get settingsConfirmationCounterDeletionSubtitle =>
      'Wenn deaktiviert, wirst du nicht mehr zum löschen eines Zeitzählers gefragt';

  @override
  String get listpageAddItem => 'Füge etwas hinzu...';

  @override
  String get listpageEditItem => 'Neuer Text zum bearbeiten';

  @override
  String get dialogConfirmTitle => 'Bestätige';

  @override
  String get dialogConfirmSubtitle => 'Möchtest du das wirklich löschen?';

  @override
  String get dialogResetSubtitle => 'Möchtest du das wirklich zurücksetzen?';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogCancel => 'Abbrechen';

  @override
  String get dialogSTTTitle => 'Du kannst jetzt sprechen';

  @override
  String get dialogSTTSubtitle =>
      'Mit dem Wort \'und\' kannst du deine Einträge trennen';

  @override
  String get dialogCounterChangeDateTime =>
      'Auf welchen Zeitpunkt willst du ändern?';

  @override
  String get dialogInvalidInput => 'Ungültige Eingabe';

  @override
  String launchUrlFailed(String finalUrl) {
    return 'Konnte $finalUrl nicht aufrufen';
  }
}
