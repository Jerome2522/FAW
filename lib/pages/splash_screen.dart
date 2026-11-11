import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/offline_ml_service.dart';
import '../services/scan_history_service.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _particleController;

  final ValueNotifier<double> _loadingProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<String> _loadingStatus = ValueNotifier<String>("Initializing...");

  @override
  void initState() {
    super.initState();
    
    // Slow repeating loop for background floating particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // No central logo reveal — keep splash simple and fast
    _initializeApp();
  }

  @override
  void dispose() {
    _particleController.dispose();
    // no logo controller to dispose
    _loadingProgress.dispose();
    _loadingStatus.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      _loadingStatus.value = "Preloading assets...";
      _loadingProgress.value = 0.2;

      await Future.wait([
        _preloadImages(),
        _warmLocalStorage(),
        _warmUpOfflineModels(),
      ]);

      _loadingStatus.value = "Welcome to FAW AI";
      _loadingProgress.value = 1.0;
    } catch (e) {
      debugPrint("Startup error: $e");
      _loadingStatus.value = "Starting offline mode...";
      _loadingProgress.value = 1.0;
    }

    // Ensure the splash screen is displayed for at least 2.8 seconds
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(milliseconds: 2800) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const FallArmywormScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<void> _preloadImages() async {
    if (!mounted) return;
    try {
      await precacheImage(const AssetImage('lib/images/icarlogo.png'), context);
    } catch (_) {}
  }

  Future<void> _warmLocalStorage() async {
    // Warm up the database scan log history cache
    await ScanHistoryService.getHistory();
  }

  Future<void> _warmUpOfflineModels() async {
    if (!mounted) return;
    _loadingStatus.value = "Loading offline AI models...";
    _loadingProgress.value = 0.6;
    try {
      await OfflineMlService.instance.initialize();
    } catch (e) {
      debugPrint("Model warmup error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Cohesive Light Agricultural Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE8EEE8), // App scaffold background (agricultural green-grey tint)
                    Color(0xFFF1F6F1), // Very light fresh mint-white
                    Color(0xFFFFFFFF), // Crisp clean white
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. Paint-Isolated Animated Subtle Floating Brand Particles
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Particle 1 (Forest green)
                      Positioned(
                        top: mediaQuery.size.height * 0.15 +
                            25 * math.sin(_particleController.value * 2 * math.pi),
                        left: mediaQuery.size.width * 0.2 +
                            15 * math.cos(_particleController.value * 2 * math.pi),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1F2D6A4F), // Constant hex alpha (0.12 of 0xFF2D6A4F)
                          ),
                        ),
                      ),
                      // Particle 2 (Fresh secondary green)
                      Positioned(
                        bottom: mediaQuery.size.height * 0.2 +
                            30 * math.cos((_particleController.value + 0.3) * 2 * math.pi),
                        right: mediaQuery.size.width * 0.25 +
                            20 * math.sin((_particleController.value + 0.3) * 2 * math.pi),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1F52B788), // Constant hex alpha (0.12 of 0xFF52B788)
                          ),
                        ),
                      ),
                      // Particle 3 (Primary green)
                      Positioned(
                        top: mediaQuery.size.height * 0.6 +
                            20 * math.cos((_particleController.value + 0.7) * 2 * math.pi),
                        left: mediaQuery.size.width * 0.15 +
                            25 * math.sin((_particleController.value + 0.7) * 2 * math.pi),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1A2D6A4F), // Constant hex alpha (0.10 of 0xFF2D6A4F)
                          ),
                        ),
                      ),
                      // Particle 4 (Primary green - New)
                      Positioned(
                        top: mediaQuery.size.height * 0.45 +
                            22 * math.sin((_particleController.value + 0.45) * 2 * math.pi),
                        right: mediaQuery.size.width * 0.18 +
                            18 * math.cos((_particleController.value + 0.45) * 2 * math.pi),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1F2D6A4F),
                          ),
                        ),
                      ),
                      // Particle 5 (Fresh secondary green - New)
                      Positioned(
                        top: mediaQuery.size.height * 0.25 +
                            28 * math.cos((_particleController.value + 0.15) * 2 * math.pi),
                        left: mediaQuery.size.width * 0.45 +
                            22 * math.sin((_particleController.value + 0.15) * 2 * math.pi),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1A52B788),
                          ),
                        ),
                      ),
                      // Particle 6 (Forest green - New)
                      Positioned(
                        bottom: mediaQuery.size.height * 0.4 +
                            18 * math.sin((_particleController.value + 0.8) * 2 * math.pi),
                        left: mediaQuery.size.width * 0.35 +
                            20 * math.cos((_particleController.value + 0.8) * 2 * math.pi),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1A2D6A4F),
                          ),
                        ),
                      ),
                      // Particle 7 (Primary green - New)
                      Positioned(
                        bottom: mediaQuery.size.height * 0.15 +
                            24 * math.cos((_particleController.value + 0.55) * 2 * math.pi),
                        left: mediaQuery.size.width * 0.6 +
                            16 * math.sin((_particleController.value + 0.55) * 2 * math.pi),
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1A2D6A4F),
                          ),
                        ),
                      ),
                      // Particle 8 (Fresh secondary green - New)
                      Positioned(
                        top: mediaQuery.size.height * 0.75 +
                            26 * math.sin((_particleController.value + 0.25) * 2 * math.pi),
                        right: mediaQuery.size.width * 0.3 +
                            24 * math.cos((_particleController.value + 0.25) * 2 * math.pi),
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1C52B788),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // 3. Central Glassmorphic Card (Premium White Glass matching the app)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Container(
                width: 280, // Enforce constant, elegant width to prevent shape-shifting
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A1B4332), // Soft forest-green tinted shadow (0.04 of 0xFF1B4332)
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xB3FFFFFF), // Ultra-premium 70% opacity white glass
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0x33FFFFFF)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 90, maxWidth: 90),
                            child: Image.asset('lib/images/icarlogo.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "FAW AI",
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B4332), // Deep forest green matching the app branding
                            ),
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<String>(
                            valueListenable: _loadingStatus,
                            builder: (context, status, _) {
                              return Text(
                                status,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF406050), // Cohesive deep mossy-gray
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: 120,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0x142D6A4F), // Cohesive primary green progress background
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: ValueListenableBuilder<double>(
                                valueListenable: _loadingProgress,
                                builder: (context, progress, _) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 120 * progress,
                                    color: const Color(0xFF2D6A4F), // App primary brand color
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. "AI-Powered Agricultural Assistant" Bottom Text
          Positioned(
            bottom: mediaQuery.padding.bottom + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "AI-Powered Agricultural Assistant",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0x991B4332), // Cohesive 60% opacity brand color
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
