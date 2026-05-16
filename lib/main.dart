import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui'; // Required for BackdropFilter
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'pages/identifcation.dart'; // Import the new page
import 'pages/damagesymptoms.dart'; // Import Damage Symptoms page
import 'pages/biology.dart'; // Import Biology page
import 'pages/management.dart'; // Import Management page
import 'pages/control.dart'; // Import Control page
import 'pages/contact.dart'; // Import Contact page
import 'pages/labs.dart'; // Import Labs page
import 'features/camera/camera_service.dart';
import 'features/prediction/prediction_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'services/pending_prediction_queue.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeIn),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
        );
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Offline Queue
  await PendingPredictionQueue.initialize();
  PendingPredictionQueue.processPending(); // Start background sync if any
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fall Armyworm',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
      ],
      locale: _locale,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF2F5F2), // Lighter lush green-grey tint
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF2D6A4F), // Deep green
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF2D6A4F),
          secondary: const Color(0xFF52B788), // Fresh green
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF2F5F2),
          foregroundColor: const Color(0xFF1B4332),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B4332),
          ),
        ),
        useMaterial3: true,
      ),
      home: const FallArmywormScreen(),
    );
  }
}

class FallArmywormScreen extends StatefulWidget {
  const FallArmywormScreen({super.key});

  @override
  State<FallArmywormScreen> createState() => _FallArmywormScreenState();
}

class _FallArmywormScreenState extends State<FallArmywormScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    print("CONNECTIVITY LISTENERS: Creating new listener in Home Screen.");
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        PendingPredictionQueue.processPending();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      _showScanOptions();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showScanOptions() async {
    final previousIndex = _selectedIndex;

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      bool? allowed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Camera Access Required"),
            content: const Text(
              "We need camera access to scan your crops for Fall Armyworm damage. Your photos are only used for analysis and are not stored without your consent."
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Not Now"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Allow"),
              ),
            ],
          );
        },
      );
      
      if (allowed != true) return;
      await Permission.camera.request();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Scan Your Crop",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF1B4332),
                        ),
                      ),
                      Text(
                        "Take or upload a photo for analysis",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2D6A4F).withOpacity(0.15),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(context, true);
                    CameraService().takePicture().then((image) {
                      _handleImage(image);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 26,
                              color: Color(0xFF2D6A4F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Take a Photo",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: const Color(0xFF1B4332),
                                ),
                              ),
                              Text(
                                "Use your camera to scan",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2D6A4F).withOpacity(0.15),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(context, true);
                    CameraService().chooseFromGallery().then((image) {
                      _handleImage(image);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.photo_library_rounded,
                              size: 26,
                              color: Color(0xFF2D6A4F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Choose from Gallery",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: const Color(0xFF1B4332),
                                ),
                              ),
                              Text(
                                "Upload an existing photo",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != true) {
        if (mounted) {
          setState(() {
            _selectedIndex = previousIndex;
          });
        }
      }
    });
  }

  void _handleImage(dynamic image) async {
    if (image != null) {
      if (!mounted) return;
      await Navigator.push(
        context,
        FadePageRoute(
          page: PredictionPage(image: image),
        ),
      );
      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    }
  }

  Widget _buildGlassBox({required Widget child, BorderRadius? borderRadius}) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  void _navigateWithFeedback(BuildContext context, Widget page) async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100)); // Prevent double tap
    if (!mounted) return;
    Navigator.push(
      context,
      FadePageRoute(page: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F2),
      extendBody: true, // Allows content to flow behind navigation bar for glass effect
      body: Stack(
        children: [
          // Background blobs for glassmorphism effect visibility
          // Top Right Blob
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 27, 62, 46).withOpacity(0.15),
              ),
            ),
          ),
          // Left Middle Blob
          Positioned(
            top: 300,
            left: -40,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 40, 162, 105).withOpacity(0.15),
              ),
            ),
          ),
          // Bottom Right Blob
          Positioned(
            bottom: 80,
            right: -20,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 85, 135, 92).withOpacity(0.5),
              ),
            ),
          ),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final inAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ));
              final outAnimation = Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ));
              
              if (child.key == ValueKey(_selectedIndex)) {
                return SlideTransition(position: inAnimation, child: child);
              } else {
                return SlideTransition(position: outAnimation, child: child);
              }
            },
            child: _selectedIndex == 0
                ? SafeArea(
                    key: const ValueKey(0),
                    bottom: false, // Don't safely inset bottom since we extended body
                    child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 100), // Add bottom padding for nav bar
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              /// 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'lib/images/icarlogo.png',
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.icarTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.bipmTitle,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<Locale>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    onSelected: (Locale locale) {
                      MyApp.setLocale(context, locale);
                    },
                    itemBuilder: (BuildContext context) {
                      final currentLocale = Localizations.localeOf(context);
                      final isEnglish = currentLocale.languageCode == 'en';
                      return [
                        PopupMenuItem(
                          value: const Locale('en'),
                          child: SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('English',
                                    style: GoogleFonts.poppins(
                                        fontWeight: isEnglish ? FontWeight.bold : FontWeight.w500,
                                        color: isEnglish ? Theme.of(context).primaryColor : Colors.black87)),
                                Icon(Icons.check_rounded,
                                    color: isEnglish ? Theme.of(context).primaryColor : Colors.transparent,
                                    size: 20),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('hi'),
                          child: SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('हिंदी (Hindi)',
                                    style: GoogleFonts.poppins(
                                        fontWeight: !isEnglish ? FontWeight.bold : FontWeight.w500,
                                        color: !isEnglish ? Theme.of(context).primaryColor : Colors.black87)),
                                Icon(Icons.check_rounded,
                                    color: !isEnglish ? Theme.of(context).primaryColor : Colors.transparent,
                                    size: 20),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(Icons.translate_rounded,
                          size: 22, color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 28),

              /// 🔹 Pest Image / Hero
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                      Image.asset(
                        "lib/images/fawhome.jpg",
                        height: MediaQuery.of(context).size.height * 0.28,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: MediaQuery.of(context).size.height * 0.28,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.appTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Spodoptera frugiperda",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔹 Description Section
              _buildGlassBox(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.overview,
                        style: GoogleFonts.poppins(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.fawDescription,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.6,
                          color: const Color(0xFF2D6A4F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              /// 🔹 Grid Section Title
              Text(
                AppLocalizations.of(context)!.infoGuide,
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 32, 68, 53),
                ),
              ),
              const SizedBox(height: 16),

              /// 🔹 Custom Grid
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridCard(
                          icon: Icons.search,
                          title: AppLocalizations.of(context)!.identification,
                          color: const Color(0xFF40916C),
                          onTap: () => _navigateWithFeedback(context, const IdentificationScreen()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGridCard(
                          icon: Icons.warning_amber_rounded,
                          title: AppLocalizations.of(context)!.damageSymptoms,
                          color: const Color(0xFFD97706),
                          onTap: () => _navigateWithFeedback(context, const DamageSymptomsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridCard(
                          icon: Icons.science_outlined,
                          title: AppLocalizations.of(context)!.biology,
                          color: const Color(0xFF7C3AED),
                          onTap: () => _navigateWithFeedback(context, const BiologyScreen()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGridCard(
                          icon: Icons.bar_chart,
                          title: AppLocalizations.of(context)!.management,
                          color: const Color(0xFF0D9488),
                          onTap: () => _navigateWithFeedback(context, const ManagementScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGridCard(
                    icon: Icons.shield_outlined,
                    title: AppLocalizations.of(context)!.controlMeasures,
                    subtitle: AppLocalizations.of(context)!.fullControlGuide,
                    color: const Color(0xFFB91C1C),
                    isFullWidth: true,
                    onTap: () => _navigateWithFeedback(context, const ControlScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      )
    : _selectedIndex == 2
        ? const LabsScreen(key: ValueKey(2))
        : _selectedIndex == 3
            ? const ContactScreen(key: ValueKey(3))
            : const SizedBox.shrink(key: ValueKey(-1)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: const Color(0xFF2E7D32),
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.green.withOpacity(0.1),
            color: Colors.grey[500]!,
            tabs: [
              GButton(
                icon: Icons.home_rounded,
                text: AppLocalizations.of(context)!.home,
              ),
              GButton(
                icon: Icons.camera_alt_rounded,
                text: 'Scan',
              ),
              GButton(
                icon: Icons.science_outlined,
                text: AppLocalizations.of(context)!.labs,
              ),
              GButton(
                icon: Icons.mail_outline,
                text: AppLocalizations.of(context)!.contact,
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return _buildGlassBox(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: isFullWidth ? 100 : 160,
        color: Colors.transparent, // Important for glass effect
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: color.withOpacity(0.1),
            highlightColor: color.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isFullWidth
                  ? Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            size: 16, color: Colors.grey[400]),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 26),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 4,
                            width: 20,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ));
  }
}

// Simple Bottom Nav replacement since GNav requires package:google_nav_bar
class GNav extends StatelessWidget {
  final List<GButton> tabs;
  final int selectedIndex;
  final Function(int) onTabChange;
  final Color activeColor;
  final Color tabBackgroundColor;
  final Color color;
  final double gap;
  final EdgeInsets padding;

  const GNav({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChange,
    required this.activeColor,
    required this.tabBackgroundColor,
    required this.color,
    this.gap = 0,
    this.padding = EdgeInsets.zero,
    // unrelated params
    Color? rippleColor,
    Color? hoverColor,
    double? iconSize,
    Duration? duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(tabs.length, (index) {
        final isActive = index == selectedIndex;
        return InkWell(
          onTap: () => onTabChange(index),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: padding,
            decoration: BoxDecoration(
              color: isActive ? tabBackgroundColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  tabs[index].icon,
                  color: isActive ? activeColor : color,
                ),
                if (isActive) ...[
                  SizedBox(width: gap),
                  Text(
                    tabs[index].text,
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class GButton {
  final IconData icon;
  final String text;

  const GButton({required this.icon, required this.text});
}