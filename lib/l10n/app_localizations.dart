import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fall Armyworm'**
  String get appTitle;

  /// No description provided for @bipmTitle.
  ///
  /// In en, this message translates to:
  /// **'BIPM FOR FAW'**
  String get bipmTitle;

  /// No description provided for @icarTitle.
  ///
  /// In en, this message translates to:
  /// **'ICAR - NBAIR'**
  String get icarTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @biology.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get biology;

  /// No description provided for @damageSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Damage Symptoms'**
  String get damageSymptoms;

  /// No description provided for @identification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get identification;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @fawDescription.
  ///
  /// In en, this message translates to:
  /// **'Fall armyworm (Spodoptera frugiperda) is a new invasive pest in India, damaging maize crop. The caterpillars mainly feed on young maize plants, cobs and tassel. They have also been recorded causing damage on sorghum and pearl millet (Bajra).'**
  String get fawDescription;

  /// No description provided for @infoGuide.
  ///
  /// In en, this message translates to:
  /// **'Information Guide'**
  String get infoGuide;

  /// No description provided for @spotThePest.
  ///
  /// In en, this message translates to:
  /// **'How to spot the pest'**
  String get spotThePest;

  /// No description provided for @signsOfInfestation.
  ///
  /// In en, this message translates to:
  /// **'Signs of infestation'**
  String get signsOfInfestation;

  /// No description provided for @lifeCycle.
  ///
  /// In en, this message translates to:
  /// **'Life cycle'**
  String get lifeCycle;

  /// No description provided for @controlMeasures.
  ///
  /// In en, this message translates to:
  /// **'Control Measures'**
  String get controlMeasures;

  /// No description provided for @effectiveStrategies.
  ///
  /// In en, this message translates to:
  /// **'Effective strategies'**
  String get effectiveStrategies;

  /// No description provided for @chemicalAndOrganic.
  ///
  /// In en, this message translates to:
  /// **'Chemical & Organic'**
  String get chemicalAndOrganic;

  /// No description provided for @labs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get labs;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @larvalStage1To3.
  ///
  /// In en, this message translates to:
  /// **'Larval growth stage: 1-3 instars'**
  String get larvalStage1To3;

  /// No description provided for @larvalStage4To6.
  ///
  /// In en, this message translates to:
  /// **'Larval growth stage: 4-6 instars'**
  String get larvalStage4To6;

  /// No description provided for @egg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get egg;

  /// No description provided for @larva.
  ///
  /// In en, this message translates to:
  /// **'Larva'**
  String get larva;

  /// No description provided for @pupa.
  ///
  /// In en, this message translates to:
  /// **'Pupa'**
  String get pupa;

  /// No description provided for @adult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adult;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @mailingAddress.
  ///
  /// In en, this message translates to:
  /// **'Mailing Address'**
  String get mailingAddress;

  /// No description provided for @directorAddress.
  ///
  /// In en, this message translates to:
  /// **'The Director\nNational Bureau of Agricultural Insect Resources\nP.Bag No:2491, H.A. Farm Post\nBellary Road, Bengaluru – 560 024\nKarnataka, INDIA.'**
  String get directorAddress;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @biocontrolLabs.
  ///
  /// In en, this message translates to:
  /// **'Biocontrol Labs'**
  String get biocontrolLabs;

  /// No description provided for @findLabsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find labs near you for biological control agents.'**
  String get findLabsSubtitle;

  /// No description provided for @noLabData.
  ///
  /// In en, this message translates to:
  /// **'No lab data found'**
  String get noLabData;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @allStates.
  ///
  /// In en, this message translates to:
  /// **'All States'**
  String get allStates;

  /// No description provided for @showingLabsIn.
  ///
  /// In en, this message translates to:
  /// **'Showing labs in '**
  String get showingLabsIn;

  /// No description provided for @noLabsFound.
  ///
  /// In en, this message translates to:
  /// **'No labs found'**
  String get noLabsFound;

  /// No description provided for @unknownLab.
  ///
  /// In en, this message translates to:
  /// **'Unknown Lab'**
  String get unknownLab;

  /// No description provided for @identificationQueries.
  ///
  /// In en, this message translates to:
  /// **'Identification Queries'**
  String get identificationQueries;

  /// No description provided for @headMarkingQuery.
  ///
  /// In en, this message translates to:
  /// **'Does it have a dark head with an inverted Y-shape marking on the front (blue circle)?'**
  String get headMarkingQuery;

  /// No description provided for @abdominalSpotsQuery.
  ///
  /// In en, this message translates to:
  /// **'Does it have four dark spots forming a square towards end of the abdomen (red circle)?'**
  String get abdominalSpotsQuery;

  /// No description provided for @headInvertedY.
  ///
  /// In en, this message translates to:
  /// **'Head: Inverted Y-shape'**
  String get headInvertedY;

  /// No description provided for @abdomenSquareSpots.
  ///
  /// In en, this message translates to:
  /// **'Abdomen: Square spots'**
  String get abdomenSquareSpots;

  /// No description provided for @symptomsOverview.
  ///
  /// In en, this message translates to:
  /// **'Symptoms Overview'**
  String get symptomsOverview;

  /// No description provided for @symptom1.
  ///
  /// In en, this message translates to:
  /// **'Fall armyworm caterpillars feed inside whorls on young plants.'**
  String get symptom1;

  /// No description provided for @symptom2.
  ///
  /// In en, this message translates to:
  /// **'Young caterpillars feed by scrapping the leaves, resulting in formation of white, semi-transparent patches on the leaves.'**
  String get symptom2;

  /// No description provided for @symptom3.
  ///
  /// In en, this message translates to:
  /// **'Damage by grown up larvae is characterized by torn appearance on leaves and presence of moist saw dust like frass near the whorls on upper leaves of the plant.'**
  String get symptom3;

  /// No description provided for @symptom4.
  ///
  /// In en, this message translates to:
  /// **'Deep feeding in the whorl may destroy developing tassels.'**
  String get symptom4;

  /// No description provided for @symptom5.
  ///
  /// In en, this message translates to:
  /// **'Caterpillars enter the cob and feed on developing kernels.'**
  String get symptom5;

  /// No description provided for @damageImageCaption.
  ///
  /// In en, this message translates to:
  /// **'Fall armyworm damage symptoms on maize crop'**
  String get damageImageCaption;

  /// No description provided for @earlyInstarDamageCaption.
  ///
  /// In en, this message translates to:
  /// **'Early instar larvae feed in the whorls and result in formation of small holes on leaves'**
  String get earlyInstarDamageCaption;

  /// No description provided for @cobDamageCaption.
  ///
  /// In en, this message translates to:
  /// **'Caterpillars feed on cobs'**
  String get cobDamageCaption;

  /// No description provided for @fullControlGuide.
  ///
  /// In en, this message translates to:
  /// **'Full control guide incl. chemicals'**
  String get fullControlGuide;

  /// No description provided for @monitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoring;

  /// No description provided for @scoutingAndThresholds.
  ///
  /// In en, this message translates to:
  /// **'Scouting and Action Thresholds'**
  String get scoutingAndThresholds;

  /// No description provided for @preventiveMeasures.
  ///
  /// In en, this message translates to:
  /// **'Preventive Measures'**
  String get preventiveMeasures;

  /// No description provided for @culturalControl.
  ///
  /// In en, this message translates to:
  /// **'Cultural Control & Best Practices'**
  String get culturalControl;

  /// No description provided for @biologicalControl.
  ///
  /// In en, this message translates to:
  /// **'Biological Control'**
  String get biologicalControl;

  /// No description provided for @naturalEnemies.
  ///
  /// In en, this message translates to:
  /// **'Natural enemies & biopesticides'**
  String get naturalEnemies;

  /// No description provided for @chemicalControl.
  ///
  /// In en, this message translates to:
  /// **'Chemical Control'**
  String get chemicalControl;

  /// No description provided for @pesticidesAndApp.
  ///
  /// In en, this message translates to:
  /// **'Pesticides & correct application'**
  String get pesticidesAndApp;

  /// No description provided for @pheromoneControl.
  ///
  /// In en, this message translates to:
  /// **'Pheromone Control'**
  String get pheromoneControl;

  /// No description provided for @trapsAndMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Traps & monitoring'**
  String get trapsAndMonitoring;

  /// No description provided for @restrictions.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get restrictions;

  /// No description provided for @safetyIntervals.
  ///
  /// In en, this message translates to:
  /// **'Safety intervals (REI)'**
  String get safetyIntervals;

  /// No description provided for @larvaStage1_3.
  ///
  /// In en, this message translates to:
  /// **'Larval growth stage: 1-3 instars'**
  String get larvaStage1_3;

  /// No description provided for @larvaStage4_6.
  ///
  /// In en, this message translates to:
  /// **'Larval growth stage: 4-6 instars'**
  String get larvaStage4_6;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
