import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class IdentificationScreen extends StatelessWidget {
  const IdentificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.identification,
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
            _buildQueryCard(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryCard(BuildContext context) {
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
            top: BorderSide(color: Color.fromARGB(255, 0, 150, 196), width: 4),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.identificationQueries,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 150, 196),
            ),
          ),
          const SizedBox(height: 15),
          const SizedBox(height: 10),
          _buildBulletPoint(
            AppLocalizations.of(context)!.headMarkingQuery,
          ),
          const SizedBox(height: 10),
          _buildBulletPoint(
            AppLocalizations.of(context)!.abdominalSpotsQuery,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildImageColumn(
                    "lib/images/identification1.jpg", // Head Y-shape close up
                    AppLocalizations.of(context)!.headInvertedY,
                    Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildImageColumn(
                    "lib/images/identification2.jpg", // Abdominal spots
                    AppLocalizations.of(context)!.abdomenSquareSpots,
                    Colors.red),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildImageColumn(
      String imageUrl, String caption, Color highlightColor) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: highlightColor.withOpacity(0.5), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 400, // Limit memory usage
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

