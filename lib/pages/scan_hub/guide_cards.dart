import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fawproto/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Farmer Education Guide",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: [
            _buildGuideCard(
              context,
              l10n.cropCareGuide,
              "🌽",
              Colors.amber.shade50,
              const Color(0xFF92400E),
              const ManagementScreen(),
            ),
            _buildGuideCard(
              context,
              l10n.pestPrevention,
              "🐛",
              Colors.red.shade50,
              const Color(0xFF991B1B),
              const DamageSymptomsScreen(),
            ),
            _buildGuideCard(
              context,
              l10n.healthyCropPractices,
              "🌱",
              Colors.green.shade50,
              const Color(0xFF065F46),
              const BiologyScreen(),
            ),
            _buildGuideCard(
              context,
              l10n.howToCapturePhotos,
              "📷",
              Colors.blue.shade50,
              const Color(0xFF1E40AF),
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
    String emoji,
    Color bg,
    Color textColor,
    Widget targetPage,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
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
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: textColor,
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
