import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import '../biology.dart';
import '../management.dart';
import '../damagesymptoms.dart';
import '../identifcation.dart';

/// Premium Fade + Slide Route Transition Builder for maximum smoothness
Route _createPremiumRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.05); // slight slide up
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class GuideCardsSection extends StatelessWidget {
  const GuideCardsSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Farmer Education",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E6B52),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildGuideCard(
              context,
              "Crop Care Guide",
              Icons.agriculture_rounded,
              const ManagementScreen(),
            ),
            _buildGuideCard(
              context,
              "Pest Prevention",
              Icons.bug_report_rounded,
              const DamageSymptomsScreen(),
            ),
            _buildGuideCard(
              context,
              "Healthy Practices",
              Icons.favorite_rounded,
              const BiologyScreen(),
            ),
            _buildGuideCard(
              context,
              "Better Image Capture",
              Icons.camera_alt_rounded,
              const IdentificationScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuideCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget targetPage,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              _createPremiumRoute(targetPage),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF1E6B52),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
