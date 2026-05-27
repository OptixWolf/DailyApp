import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @sTTSeperateWord.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get sTTSeperateWord;

  /// No description provided for @categoryLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get categoryLists;

  /// No description provided for @categoryCounters.
  ///
  /// In en, this message translates to:
  /// **'Time Counters'**
  String get categoryCounters;

  /// No description provided for @categorySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get categorySettings;

  /// No description provided for @generalFabTitle.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get generalFabTitle;

  /// No description provided for @generalSwitchIndicators.
  ///
  /// In en, this message translates to:
  /// **'Change sorting indicators'**
  String get generalSwitchIndicators;

  /// No description provided for @generalDeleteAllEntries.
  ///
  /// In en, this message translates to:
  /// **'Delete all entries'**
  String get generalDeleteAllEntries;

  /// No description provided for @generalFieldMustNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This field must not be empty!'**
  String get generalFieldMustNotBeEmpty;

  /// No description provided for @generalNoEntriesFound.
  ///
  /// In en, this message translates to:
  /// **'No entries found'**
  String get generalNoEntriesFound;

  /// No description provided for @listsNoListMessage.
  ///
  /// In en, this message translates to:
  /// **'No lists available'**
  String get listsNoListMessage;

  /// No description provided for @listsExampleName.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get listsExampleName;

  /// No description provided for @listsEditFieldText.
  ///
  /// In en, this message translates to:
  /// **'New Name for list'**
  String get listsEditFieldText;

  /// No description provided for @listsNameMustNotBeDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Name must not be duplicated!'**
  String get listsNameMustNotBeDuplicate;

  /// No description provided for @countersExampleName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get countersExampleName;

  /// No description provided for @countersEditFieldText.
  ///
  /// In en, this message translates to:
  /// **'New Name for Counter'**
  String get countersEditFieldText;

  /// Shows how long something has been running
  ///
  /// In en, this message translates to:
  /// **'Running since: {days}d {hours}h {minutes}min {seconds}s'**
  String counterRunningFor(int days, int hours, int minutes, int seconds);

  /// No description provided for @settingsTitleGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settingsTitleGeneral;

  /// No description provided for @settingsRepoTitle.
  ///
  /// In en, this message translates to:
  /// **'Source Code (External)'**
  String get settingsRepoTitle;

  /// No description provided for @settingsRepoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can find the projects GitHub Repository here'**
  String get settingsRepoSubtitle;

  /// No description provided for @settingsDarkmodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Darkmode'**
  String get settingsDarkmodeTitle;

  /// No description provided for @settingsDarkmodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled the app uses darkmode'**
  String get settingsDarkmodeSubtitle;

  /// No description provided for @settingsConfirmationsForDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirmations for deletion'**
  String get settingsConfirmationsForDeletion;

  /// No description provided for @settingsConfirmationListDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the deletion of lists'**
  String get settingsConfirmationListDeletionTitle;

  /// No description provided for @settingsConfirmationListDeletionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If disabled, you will no longer be asked to delete a list'**
  String get settingsConfirmationListDeletionSubtitle;

  /// No description provided for @settingsConfirmationListEntryDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the deletion of list entries'**
  String get settingsConfirmationListEntryDeletionTitle;

  /// No description provided for @settingsConfirmationListEntryDeletionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If disabled, you will no longer be asked to delete a list entry'**
  String get settingsConfirmationListEntryDeletionSubtitle;

  /// No description provided for @settingsConfirmationCounterDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the deletion of counters'**
  String get settingsConfirmationCounterDeletionTitle;

  /// No description provided for @settingsConfirmationCounterDeletionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If disabled, you will no longer be asked to delete a counter'**
  String get settingsConfirmationCounterDeletionSubtitle;

  /// No description provided for @listpageAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add an item...'**
  String get listpageAddItem;

  /// No description provided for @listpageEditItem.
  ///
  /// In en, this message translates to:
  /// **'Enter new text'**
  String get listpageEditItem;

  /// No description provided for @dialogConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirmTitle;

  /// No description provided for @dialogConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get dialogConfirmSubtitle;

  /// No description provided for @dialogResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset this?'**
  String get dialogResetSubtitle;

  /// No description provided for @dialogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOk;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogSTTTitle.
  ///
  /// In en, this message translates to:
  /// **'You may speak now'**
  String get dialogSTTTitle;

  /// No description provided for @dialogSTTSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can use the word \'and\' to separate your entries'**
  String get dialogSTTSubtitle;

  /// No description provided for @dialogCounterChangeDateTime.
  ///
  /// In en, this message translates to:
  /// **'What time and date you want to change it?'**
  String get dialogCounterChangeDateTime;

  /// No description provided for @dialogInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get dialogInvalidInput;

  /// The Url which cannot be launched
  ///
  /// In en, this message translates to:
  /// **'Could not launch {finalUrl}'**
  String launchUrlFailed(String finalUrl);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
