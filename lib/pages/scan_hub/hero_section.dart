import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Custom Premium Parallax & Particle Hero Section Widget
class PremiumHeroSection extends StatefulWidget {
  final String title;
  final String subtitle;
  const PremiumHeroSection({super.key, required this.title, required this.subtitle});

  @override
  State<PremiumHeroSection> createState() => _PremiumHeroSectionState();
}

class _PremiumHeroSectionState extends State<PremiumHeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4332).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Slow moving floating particles
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: 40 + 20 * math.sin(_controller.value * 2 * math.pi),
                        left: 30 + 15 * math.cos(_controller.value * 2 * math.pi),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50 + 25 * math.cos(_controller.value * 2 * math.pi),
                        right: 40 + 20 * math.sin(_controller.value * 2 * math.pi),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100 + 15 * math.cos((_controller.value + 0.5) * 2 * math.pi),
                        right: 80 + 25 * math.sin((_controller.value + 0.5) * 2 * math.pi),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Parallax plant/leaf animation in background
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final angle = 0.05 * math.sin(_controller.value * 2 * math.pi);
                  return Positioned(
                    right: -30,
                    bottom: -20,
                    child: Transform.rotate(
                      angle: angle,
                      child: Opacity(
                        opacity: 0.15,
                        child: const Icon(
                          Icons.local_florist_rounded,
                          size: 260,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.local_florist_rounded, size: 28, color: Colors.green[200]),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF52B788),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.qr_code_scanner_rounded, size: 10, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
