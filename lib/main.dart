import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/app_localizations.dart';
import 'pages/splash_screen.dart';
import 'pages/contact.dart';
import 'pages/labs.dart';
import 'pages/scan_hub.dart';
import 'pages/identifcation.dart';
import 'pages/damagesymptoms.dart';
import 'pages/biology.dart';
import 'pages/management.dart';
import 'pages/control.dart';
import 'config/firebase_options.dart';
import 'services/pending_prediction_queue.dart';
import 'widgets/navigation/lazy_indexed_stack_child.dart';
import 'widgets/navigation/fade_indexed_stack.dart';
import 'widgets/navigation/bottom_nav.dart';
import 'widgets/navigation/safe_navigator.dart';

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
          transitionDuration: const Duration(milliseconds: 350),
        );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set highly optimized image cache constraints for low-end agricultural devices
  PaintingBinding.instance.imageCache.maximumSize = 80; // Cache maximum 80 images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 25 * 1024 * 1024; // Cap cache memory at 25 MB
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init skipped/offline: $e");
  }

  // Initialize legacy queue cleanup (non-blocking)
  await PendingPredictionQueue.initialize();
  PendingPredictionQueue.processPending();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

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
        scaffoldBackgroundColor: const Color(0xFFE8EEE8), // Richer agricultural green-grey tint
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF2D6A4F), // Deep green
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF2D6A4F),
          secondary: const Color(0xFF52B788), // Fresh green
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFE8EEE8),
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
      home: const SplashScreen(),
    );
  }
}

class FallArmywormScreen extends StatefulWidget {
  const FallArmywormScreen({super.key});

  @override
  State<FallArmywormScreen> createState() => _FallArmywormScreenState();
}

class _FallArmywormScreenState extends State<FallArmywormScreen> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  int _lastIndex = 0;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final offline = results.isEmpty || results.first == ConnectivityResult.none;
      if (!offline) {
        PendingPredictionQueue.processPending();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _selectedIndex.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    _lastIndex = _selectedIndex.value;
    _selectedIndex.value = index;
  }

  void navigateToPreviousTab() {
    HapticFeedback.lightImpact();
    _selectedIndex.value = _lastIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    final l10n = AppLocalizations.of(context)!;

    final navItems = [
      (Icons.home_rounded, l10n.home),
      (Icons.camera_alt_rounded, l10n.scan),
      (Icons.science_outlined, l10n.labs),
      (Icons.mail_outline, l10n.contact),
    ];

    Widget bodyContent;
    if (isWide) {
      // ── Wide layout: side rail + content ──────────────────────────────────
      bodyContent = Scaffold(
        backgroundColor: const Color(0xFFE8EEE8),
        body: Stack(
          children: [
            // Background blobs
            Positioned(
              top: -40, right: -40,
              child: Container(
                height: 200, width: 200,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x261B3E2E)),
              ),
            ),
            Positioned(
              top: 300, left: -40,
              child: Container(
                height: 160, width: 160,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x2628A269)),
              ),
            ),
            Row(
              children: [
                // Side navigation rail
                ValueListenableBuilder<int>(
                  valueListenable: _selectedIndex,
                  builder: (context, idx, _) => SafeArea(
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Image.asset('lib/images/icarlogo.png', height: 36, fit: BoxFit.contain),
                          const SizedBox(height: 24),
                          ...List.generate(navItems.length, (i) {
                            final isSelected = idx == i;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              child: GestureDetector(
                                onTap: () => _onItemTapped(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E6B52).withValues(alpha: 0.12)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        navItems[i].$1,
                                        color: isSelected ? const Color(0xFF1E6B52) : Colors.grey[500],
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        navItems[i].$2,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                                          color: isSelected ? const Color(0xFF1E6B52) : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content area
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _selectedIndex,
                    builder: (context, idx, _) => FadeIndexedStack(
                      index: idx,
                      children: [
                        LazyIndexedStackChild(isActivated: idx == 0, child: const HomeDashboard()),
                        LazyIndexedStackChild(isActivated: idx == 1, child: const ScanHubPage()),
                        LazyIndexedStackChild(isActivated: idx == 2, child: const LabsScreen()),
                        LazyIndexedStackChild(isActivated: idx == 3, child: const ContactScreen()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // ── Narrow layout: original bottom nav ───────────────────────────────────
      bodyContent = Scaffold(
      backgroundColor: const Color(0xFFE8EEE8),
      extendBody: true,
      body: Stack(
        children: [
          // Background blobs for glassmorphism effect visibility
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x261B3E2E),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -40,
            child: Container(
              height: 160,
              width: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x2628A269),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -20,
            child: Container(
              height: 180,
              width: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x7F55875C),
              ),
            ),
          ),
          
          ValueListenableBuilder<int>(
            valueListenable: _selectedIndex,
            builder: (context, idx, _) {
              return FadeIndexedStack(
                index: idx,
                children: [
                  LazyIndexedStackChild(
                    isActivated: idx == 0,
                    child: const HomeDashboard(),
                  ),
                  LazyIndexedStackChild(
                    isActivated: idx == 1,
                    child: const ScanHubPage(),
                  ),
                  LazyIndexedStackChild(
                    isActivated: idx == 2,
                    child: const LabsScreen(),
                  ),
                  LazyIndexedStackChild(
                    isActivated: idx == 3,
                    child: const ContactScreen(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: RepaintBoundary(
        child: ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (context, idx, _) {
            // Hide global bottom navigation when ScanHub page is active (index 1)
            if (idx == 1) return const SizedBox.shrink();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xA6FFFFFF),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xCCFFFFFF),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: GNav(
                        rippleColor: const Color(0x33FFFFFF),
                        hoverColor: const Color(0x19FFFFFF),
                        gap: 8,
                        activeColor: const Color(0xFF1B4332),
                        iconSize: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        duration: const Duration(milliseconds: 300),
                        tabBackgroundColor: const Color(0x2652B788),
                        color: const Color(0x992D6A4F),
                        tabs: [
                          GButton(icon: Icons.home_rounded, text: l10n.home),
                          GButton(icon: Icons.camera_alt_rounded, text: l10n.scan),
                          GButton(icon: Icons.science_outlined, text: l10n.labs),
                          GButton(icon: Icons.mail_outline, text: l10n.contact),
                        ],
                        selectedIndex: idx,
                        onTabChange: _onItemTapped,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    }

    return PopScope(
      canPop: _selectedIndex.value == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex.value != 0) {
          setState(() {
            _lastIndex = _selectedIndex.value;
            _selectedIndex.value = 0;
          });
        }
      },
      child: bodyContent,
    );
  }
}

class GlassBox extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;

  const GlassBox({
    super.key,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xA6FFFFFF), // Glass white alpha
        borderRadius: radius,
        border: Border.all(
          color: const Color(0xCCFFFFFF), // Border white alpha
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class GridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  const GridCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final splashColor = Color.fromARGB(26, (color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round());
    final highlightColor = Color.fromARGB(13, (color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round());
    final circleColor = Color.fromARGB(26, (color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round());
    final barColor = Color.fromARGB(77, (color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round());

    return GlassBox(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: isFullWidth ? 100 : 160,
        color: Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: splashColor,
            highlightColor: highlightColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isFullWidth
                  ? Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: circleColor,
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
                                  subtitle!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF9E9E9E), // Hardcoded grey Color
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9F9F9), // const grey[50]
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: Color(0xFFBDBDBD)), // const grey[400]
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
                            color: circleColor,
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
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 4,
                              width: 20,
                              decoration: BoxDecoration(
                                color: barColor,
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
      ),
    );
  }
}

class LanguageSwitcher extends StatelessWidget {
  final Function(Locale) onLocaleSelected;

  const LanguageSwitcher({super.key, required this.onLocaleSelected});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final isEnglish = currentLocale.languageCode == 'en';
    final primaryColor = Theme.of(context).primaryColor;

    return PopupMenuButton<Locale>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      onSelected: onLocaleSelected,
      itemBuilder: (BuildContext context) {
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
                          color: isEnglish ? primaryColor : Colors.black87)),
                  Icon(Icons.check_rounded,
                      color: isEnglish ? primaryColor : Colors.transparent,
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
                          color: !isEnglish ? primaryColor : Colors.black87)),
                  Icon(Icons.check_rounded,
                      color: !isEnglish ? primaryColor : Colors.transparent,
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
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000), // shadow alpha
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Icon(Icons.translate_rounded,
            size: 22, color: primaryColor),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimations = List.generate(5, (index) {
      final start = 0.2 + (index * 0.12);
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _slideAnimations = List.generate(5, (index) {
      final start = 0.2 + (index * 0.12);
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateWithFeedback(BuildContext context, Widget page) async {
    HapticFeedback.lightImpact();
    if (!context.mounted) return;
    SafeNavigator.push(
      context,
      FadePageRoute(page: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Cached MediaQuery size
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
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
                            l10n.icarTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            l10n.bipmTitle,
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
                LanguageSwitcher(
                  onLocaleSelected: (Locale locale) {
                    MyApp.setLocale(context, locale);
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// 🔹 Pest Image / Hero
            RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D2D6A4F), // Shadow alpha
                      blurRadius: 25,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'faw_hero_image',
                        child: Image.asset(
                          "lib/images/fawhome.jpg",
                          height: size.height * 0.28,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: size.height * 0.28,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 40, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: size.height * 0.28,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xB2000000), // Gradient alpha
                            ],
                            stops: [0.6, 1.0],
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
                              l10n.appTitle,
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
                              style: const TextStyle(
                                color: Color(0xF2FFFFFF), // Subtitle alpha
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                shadows: [
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
            ),

            const SizedBox(height: 24),

            /// 🔹 Description Section
            GlassBox(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.overview,
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B4332),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.fawDescription,
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
              l10n.infoGuide,
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
                      child: FadeTransition(
                        opacity: _fadeAnimations[0],
                        child: SlideTransition(
                          position: _slideAnimations[0],
                          child: GridCard(
                            icon: Icons.search,
                            title: l10n.identification,
                            color: const Color(0xFF40916C),
                            onTap: () => _navigateWithFeedback(context, const IdentificationScreen()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimations[1],
                        child: SlideTransition(
                          position: _slideAnimations[1],
                          child: GridCard(
                            icon: Icons.warning_amber_rounded,
                            title: l10n.damageSymptoms,
                            color: const Color(0xFFD97706),
                            onTap: () => _navigateWithFeedback(context, const DamageSymptomsScreen()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: SlideTransition(
                          position: _slideAnimations[2],
                          child: GridCard(
                            icon: Icons.science_outlined,
                            title: l10n.biology,
                            color: const Color(0xFF7C3AED),
                            onTap: () => _navigateWithFeedback(context, const BiologyScreen()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimations[3],
                        child: SlideTransition(
                          position: _slideAnimations[3],
                          child: GridCard(
                            icon: Icons.bar_chart,
                            title: l10n.management,
                            color: const Color(0xFF0D9488),
                            onTap: () => _navigateWithFeedback(context, const ManagementScreen()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimations[4],
                  child: SlideTransition(
                    position: _slideAnimations[4],
                    child: GridCard(
                      icon: Icons.shield_outlined,
                      title: l10n.controlMeasures,
                      subtitle: l10n.fullControlGuide,
                      color: const Color(0xFFB91C1C),
                      isFullWidth: true,
                      onTap: () => _navigateWithFeedback(context, const ControlScreen()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    ),
    );
  }
}