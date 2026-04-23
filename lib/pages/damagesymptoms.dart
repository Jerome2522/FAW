import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class DamageSymptomsScreen extends StatelessWidget {
  const DamageSymptomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.damageSymptoms,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildImagesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Colors.orange, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.symptomsOverview,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 15),
          _buildBulletPoint(
              AppLocalizations.of(context)!.symptom1),
          const SizedBox(height: 10),
          _buildBulletPoint(
              AppLocalizations.of(context)!.symptom2),
          const SizedBox(height: 10),
          _buildBulletPoint(
              AppLocalizations.of(context)!.symptom3),
          const SizedBox(height: 10),
          _buildBulletPoint(
              AppLocalizations.of(context)!.symptom4),
          const SizedBox(height: 10),
          _buildBulletPoint(
              AppLocalizations.of(context)!.symptom5),
        ],
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return Column(
      children: [
        _buildImageCard(
          "lib/images/fawdamage1.jpg", // Placeholder for crop damage
          AppLocalizations.of(context)!.damageImageCaption,
          isFullWidth: true,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildImageCard(
                "lib/images/fawdamage2.jpg", // Placeholder for early instar/holes
                AppLocalizations.of(context)!.earlyInstarDamageCaption,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildImageCard(
                "lib/images/fawdamage3.jpg", // Placeholder for cob damage
                AppLocalizations.of(context)!.cobDamageCaption,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, right: 10),
          child: Icon(Icons.circle, size: 8, color: Colors.black87),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(String imageUrl, String caption, {bool isFullWidth = false}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              height: isFullWidth ? 200 : 150,
              width: double.infinity,
              cacheWidth: 600, // Optimize memory
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
        const SizedBox(height: 8),
        Text(
          caption,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}