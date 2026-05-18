import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class DamageSymptomsScreen extends StatelessWidget {
  const DamageSymptomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEE8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.damageSymptoms,
          style: GoogleFonts.outfit(
            color: const Color(0xFF1B4332),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 32),
            _buildImagesSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.symptomsOverview,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 16),
        _buildBulletPoint(AppLocalizations.of(context)!.symptom1, accentColor: const Color(0xFFE65C00)),
        _buildBulletPoint(AppLocalizations.of(context)!.symptom2, accentColor: const Color(0xFFE65C00)),
        _buildBulletPoint(AppLocalizations.of(context)!.symptom3, accentColor: const Color(0xFFE65C00)),
        _buildBulletPoint(AppLocalizations.of(context)!.symptom4, accentColor: const Color(0xFFE65C00)),
        _buildBulletPoint(AppLocalizations.of(context)!.symptom5, accentColor: const Color(0xFFE65C00)),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Damage Evidence",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 12),
        _buildImageCard(
          "lib/images/fawdamage1.jpg",
          AppLocalizations.of(context)!.damageImageCaption,
          isFullWidth: true,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildImageCard(
                "lib/images/fawdamage2.jpg",
                AppLocalizations.of(context)!.earlyInstarDamageCaption,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageCard(
                "lib/images/fawdamage3.jpg",
                AppLocalizations.of(context)!.cobDamageCaption,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, {required Color accentColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 14, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.45,
                color: const Color(0xFF1B4332),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imageUrl, String caption, {bool isFullWidth = false}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              height: isFullWidth ? 200 : 150,
              width: double.infinity,
              cacheWidth: 600,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: isFullWidth ? 200 : 150,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          caption,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D6A4F),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}