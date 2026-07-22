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

  /// No description provided for @fieldScouting.
  ///
  /// In en, this message translates to:
  /// **'Field Scouting'**
  String get fieldScouting;

  /// No description provided for @bcItem1.
  ///
  /// In en, this message translates to:
  /// **'At early crop stage (15-30 days after sowing): Release egg parasitoid. Trichogramma pretiosum @ 3 cards (50000 eggs)/acre - two times at 15 days interval. (Egg cards are available at NBAIR, Hebbal and RCIPMC, Kadugodi, Bangalore and State biocontrol labs).'**
  String get bcItem1;

  /// No description provided for @monItem2.
  ///
  /// In en, this message translates to:
  /// **'Mid stage (30-50 days after sowing) - 10-20% damaged plants.'**
  String get monItem2;

  /// No description provided for @reiTitle.
  ///
  /// In en, this message translates to:
  /// **'Restricted Entry Interval (REI)'**
  String get reiTitle;

  /// No description provided for @ccItem1.
  ///
  /// In en, this message translates to:
  /// **'Spraying of Spinetoram 11.7 SC @ 0.5ml or Chlorantraniliprole 18.5 SC @ 0.4ml. Thiamethoxam 12.6% + lambda cyhalothrin 9.5% ZC.'**
  String get ccItem1;

  /// No description provided for @larva1_3Item2.
  ///
  /// In en, this message translates to:
  /// **'After hatching, the young caterpillars feed superficially on the leaves by scrapping and it results in appearance of semi-transparent white patches on the leaves.'**
  String get larva1_3Item2;

  /// No description provided for @phItem2.
  ///
  /// In en, this message translates to:
  /// **'Install pheromone traps @ 15/acre for mass trapping of the male moths.'**
  String get phItem2;

  /// No description provided for @larva1_3Item3.
  ///
  /// In en, this message translates to:
  /// **'Young caterpillars move to the new plants by spinning silken thread.'**
  String get larva1_3Item3;

  /// No description provided for @larva4_6Item3.
  ///
  /// In en, this message translates to:
  /// **'Feeding on young plants can kill the growing point, resulting in no new leaves or cobs development.'**
  String get larva4_6Item3;

  /// No description provided for @pmItem2.
  ///
  /// In en, this message translates to:
  /// **'Wherever possible, sow early at first rain and follow synchronous planting in entire maize area to reduce population build up and multiple generations of FAW.'**
  String get pmItem2;

  /// No description provided for @larva1_3Item1.
  ///
  /// In en, this message translates to:
  /// **'Caterpillars prefer to feed in leaf whorls of young plants and feed more actively during night time.'**
  String get larva1_3Item1;

  /// No description provided for @lifecycleItem1.
  ///
  /// In en, this message translates to:
  /// **'The adult female moth lays 100-200 eggs on the leaves.'**
  String get lifecycleItem1;

  /// No description provided for @monItem1.
  ///
  /// In en, this message translates to:
  /// **'Early to mid whorl stage (15-30 days after sowing) - 5 to 10% damaged plants.'**
  String get monItem1;

  /// No description provided for @monItem3.
  ///
  /// In en, this message translates to:
  /// **'Install pheromone traps @ 4/acre soon after sowing and monitor moth catches.'**
  String get monItem3;

  /// No description provided for @biologicalSolutions.
  ///
  /// In en, this message translates to:
  /// **'Biological Solutions'**
  String get biologicalSolutions;

  /// No description provided for @pmItem3.
  ///
  /// In en, this message translates to:
  /// **'Intercrop/Alley/Mixed crop of maize with suitable pulse crops of particular region (pigeon pea/black gram/green gram).'**
  String get pmItem3;

  /// No description provided for @actionThresholds.
  ///
  /// In en, this message translates to:
  /// **'Action Thresholds'**
  String get actionThresholds;

  /// No description provided for @ccItem3.
  ///
  /// In en, this message translates to:
  /// **'Collection and destruction of egg masses and neonate larvae whenever seen in the field.'**
  String get ccItem3;

  /// No description provided for @ccItem2.
  ///
  /// In en, this message translates to:
  /// **'Application of 5% NSKE / neem formulation - Azadirachtin 10000 ppm @ 2 ml per liter of water to kill eggs and neonate larvae.'**
  String get ccItem2;

  /// No description provided for @phItem3.
  ///
  /// In en, this message translates to:
  /// **'Community action for mass trapping will give successful control.'**
  String get phItem3;

  /// No description provided for @keyPreventiveStrategies.
  ///
  /// In en, this message translates to:
  /// **'Key Preventive Strategies'**
  String get keyPreventiveStrategies;

  /// No description provided for @larva4_6Item4.
  ///
  /// In en, this message translates to:
  /// **'Large quantities of frass (caterpillar excreta) is seen in the whorl. When this dries, it resembles saw dust.'**
  String get larva4_6Item4;

  /// No description provided for @phItem4.
  ///
  /// In en, this message translates to:
  /// **'The antennal response of adult S.frugiperda males to (Z)-9-Tetradecenylacetate confirmed the physiological response of the antennal neurons to pheromone.'**
  String get phItem4;

  /// No description provided for @lifecycleItem2.
  ///
  /// In en, this message translates to:
  /// **'The eggs are covered in cream coloured protective scales. In 3-4 days neonates emerge from eggs and complete their life cycle in 36-42 days.'**
  String get lifecycleItem2;

  /// No description provided for @larva4_6Item2.
  ///
  /// In en, this message translates to:
  /// **'Often there are only 1 or 2 caterpillars in each whorl as they become cannibalistic.'**
  String get larva4_6Item2;

  /// No description provided for @chemicalControlMeasures.
  ///
  /// In en, this message translates to:
  /// **'Chemical Control Measures'**
  String get chemicalControlMeasures;

  /// No description provided for @larva4_6Item1.
  ///
  /// In en, this message translates to:
  /// **'By stage 4-6, it reaches plant whorl and causes maximum damage to the plant and produces ragged holes in the leaves.'**
  String get larva4_6Item1;

  /// No description provided for @monItem5.
  ///
  /// In en, this message translates to:
  /// **'Observe for the presence of egg mass or white patches on leaves. At later stages observe for damage on leaves (elongated holes, torn appearance with frass).'**
  String get monItem5;

  /// No description provided for @pmItem1.
  ///
  /// In en, this message translates to:
  /// **'Deep ploughing to expose pupae for predation and direct exposure to sun light.'**
  String get pmItem1;

  /// No description provided for @lifecycleItem3.
  ///
  /// In en, this message translates to:
  /// **'The Fall armyworm life cycle includes egg, 6 larval stages (instars), pupa and adult.'**
  String get lifecycleItem3;

  /// No description provided for @monItem6.
  ///
  /// In en, this message translates to:
  /// **'Start scouting as soon as maize seedlings emerge and observe for the presence of damage symptoms.'**
  String get monItem6;

  /// No description provided for @sprayNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Spray should be directed into the leaf whorls.'**
  String get sprayNote;

  /// No description provided for @pheromoneTraps.
  ///
  /// In en, this message translates to:
  /// **'Pheromone Traps'**
  String get pheromoneTraps;

  /// No description provided for @phItem5.
  ///
  /// In en, this message translates to:
  /// **'The major compound for FAW, S.frugiperda pheromone (Z)-9-Tetradecenylacetate (as major component) was characterized using chemical detectors and biological detector.'**
  String get phItem5;

  /// No description provided for @phItem1.
  ///
  /// In en, this message translates to:
  /// **'Controlled released dispenser developed at ICAR-NBAIR is effective for over 45 days.'**
  String get phItem1;

  /// No description provided for @pmItem4.
  ///
  /// In en, this message translates to:
  /// **'Follow proper crop management process through recommended dose of manures and fertilizers.'**
  String get pmItem4;

  /// No description provided for @larva4_6Item5.
  ///
  /// In en, this message translates to:
  /// **'On the older plants, caterpillar bores into the cobs and feeds on the developing kernels (seeds).'**
  String get larva4_6Item5;

  /// No description provided for @bcItem2.
  ///
  /// In en, this message translates to:
  /// **'Metarhizium rileyi (= Nomuraea rileyi) and Metarhizium anisopliae infects several species of Lepidoptera. Spray M. rileyi @ 2-3 grams per liter of water (It is available at UAS, Dharwad) or M. anisopliae @ 3 grams per liter (it is available in all state biocontrol labs).'**
  String get bcItem2;

  /// No description provided for @bcItem3.
  ///
  /// In en, this message translates to:
  /// **'Application of Bt insecticide @ 2 ml/litre. Give 2-3 sprays at 10 days interval.'**
  String get bcItem3;

  /// No description provided for @reiItem1.
  ///
  /// In en, this message translates to:
  /// **'Spinetoram - Four hours'**
  String get reiItem1;

  /// No description provided for @reiItem2.
  ///
  /// In en, this message translates to:
  /// **'Chlorantraniliprole - 12 hours.'**
  String get reiItem2;

  /// No description provided for @reiItem3.
  ///
  /// In en, this message translates to:
  /// **'Thiamethaxam + lambda cyhalothrin - 24 hours.'**
  String get reiItem3;

  /// No description provided for @reiItem4.
  ///
  /// In en, this message translates to:
  /// **'Bt insecticide - One day'**
  String get reiItem4;

  /// No description provided for @monItem4.
  ///
  /// In en, this message translates to:
  /// **'Later stage (50-70 days after sowing) - more than 20% damaged plants.'**
  String get monItem4;

  /// No description provided for @scanYourCrop.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Crop'**
  String get scanYourCrop;

  /// No description provided for @captureLeafInsect.
  ///
  /// In en, this message translates to:
  /// **'Capture a leaf or insect image for FAW AI analysis'**
  String get captureLeafInsect;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose From Gallery'**
  String get chooseFromGallery;

  /// No description provided for @tipsForDetection.
  ///
  /// In en, this message translates to:
  /// **'Tips for Better Detection'**
  String get tipsForDetection;

  /// No description provided for @tipOneSubject.
  ///
  /// In en, this message translates to:
  /// **'Capture only one subject'**
  String get tipOneSubject;

  /// No description provided for @tipKeepFocused.
  ///
  /// In en, this message translates to:
  /// **'Keep image focused'**
  String get tipKeepFocused;

  /// No description provided for @tipMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer to crop'**
  String get tipMoveCloser;

  /// No description provided for @tipUseDaylight.
  ///
  /// In en, this message translates to:
  /// **'Use daylight if possible'**
  String get tipUseDaylight;

  /// No description provided for @tipAvoidUnrelated.
  ///
  /// In en, this message translates to:
  /// **'Avoid unrelated objects'**
  String get tipAvoidUnrelated;

  /// No description provided for @recentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get recentScans;

  /// No description provided for @recentImages.
  ///
  /// In en, this message translates to:
  /// **'Recent Images'**
  String get recentImages;

  /// No description provided for @cropCareGuide.
  ///
  /// In en, this message translates to:
  /// **'Crop Care Guide'**
  String get cropCareGuide;

  /// No description provided for @pestPrevention.
  ///
  /// In en, this message translates to:
  /// **'Pest Prevention'**
  String get pestPrevention;

  /// No description provided for @healthyCropPractices.
  ///
  /// In en, this message translates to:
  /// **'Healthy Crop Practices'**
  String get healthyCropPractices;

  /// No description provided for @howToCapturePhotos.
  ///
  /// In en, this message translates to:
  /// **'How to Capture Better Photos'**
  String get howToCapturePhotos;

  /// No description provided for @scanHub.
  ///
  /// In en, this message translates to:
  /// **'Scan Hub'**
  String get scanHub;
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
