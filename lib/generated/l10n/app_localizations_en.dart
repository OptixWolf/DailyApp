// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sTTSeperateWord => ' and ';

  @override
  String get categoryLists => 'Lists';

  @override
  String get categoryCounters => 'Time Counters';

  @override
  String get categorySettings => 'Settings';

  @override
  String get generalFabTitle => 'Save';

  @override
  String get generalSwitchIndicators => 'Change sorting indicators';

  @override
  String get generalDeleteAllEntries => 'Delete all entries';

  @override
  String get generalFieldMustNotBeEmpty => 'This field must not be empty!';

  @override
  String get generalNoEntriesFound => 'No entries found';

  @override
  String get listsNoListMessage => 'No lists available';

  @override
  String get listsExampleName => 'Shopping list';

  @override
  String get listsEditFieldText => 'New Name for list';

  @override
  String get listsNameMustNotBeDuplicate => 'Name must not be duplicated!';

  @override
  String get countersExampleName => 'Name';

  @override
  String get countersEditFieldText => 'New Name for Counter';

  @override
  String counterRunningFor(int days, int hours, int minutes, int seconds) {
    return 'Running since: ${days}d ${hours}h ${minutes}min ${seconds}s';
  }

  @override
  String get settingsTitleGeneral => 'General Settings';

  @override
  String get settingsRepoTitle => 'Source Code (External)';

  @override
  String get settingsRepoSubtitle =>
      'You can find the projects GitHub Repository here';

  @override
  String get settingsDarkmodeTitle => 'Darkmode';

  @override
  String get settingsDarkmodeSubtitle => 'When enabled the app uses darkmode';

  @override
  String get settingsDynamicThemeTitle => 'Dynamic Design';

  @override
  String get settingsDynamicThemeSubtitle =>
      'When enabled the app tries to use the device theme colors';

  @override
  String get settingsConfirmationsForDeletion => 'Confirmations for deletion';

  @override
  String get settingsConfirmationListDeletionTitle =>
      'Confirm the deletion of lists';

  @override
  String get settingsConfirmationListDeletionSubtitle =>
      'If disabled, you will no longer be asked to delete a list';

  @override
  String get settingsConfirmationListEntryDeletionTitle =>
      'Confirm the deletion of list entries';

  @override
  String get settingsConfirmationListEntryDeletionSubtitle =>
      'If disabled, you will no longer be asked to delete a list entry';

  @override
  String get settingsConfirmationCounterDeletionTitle =>
      'Confirm the deletion of counters';

  @override
  String get settingsConfirmationCounterDeletionSubtitle =>
      'If disabled, you will no longer be asked to delete a counter';

  @override
  String get listpageAddItem => 'Add an item...';

  @override
  String get listpageEditItem => 'Enter new text';

  @override
  String get dialogConfirmTitle => 'Confirm';

  @override
  String get dialogConfirmSubtitle => 'Are you sure you want to delete this?';

  @override
  String get dialogResetSubtitle => 'Are you sure you want to reset this?';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogSTTTitle => 'You may speak now';

  @override
  String get dialogSTTSubtitle =>
      'You can use the word \'and\' to separate your entries';

  @override
  String get dialogCounterChangeDateTime =>
      'What time and date you want to change it?';

  @override
  String get dialogInvalidInput => 'Invalid Input';

  @override
  String launchUrlFailed(String finalUrl) {
    return 'Could not launch $finalUrl';
  }
}
