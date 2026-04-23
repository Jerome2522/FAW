import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../subpages/lifecycle.dart'; // Import the Life Cycle screen
import '../subpages/larva1-3.dart'; // Import the Larva 1-3 screen
import '../subpages/larva4-6.dart'; // Import the Larva 4-6 screen

class BiologyScreen extends StatelessWidget {
  const BiologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.biology,
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
          children: [
            _buildBiologyOption(
              context,
              AppLocalizations.of(context)!.lifeCycle,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LifeCycleScreen()),
              ),
            ),
            _buildBiologyOption(
              context,
              AppLocalizations.of(context)!.larvalStage1To3,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Larva1To3Screen()),
              ),
            ),
            _buildBiologyOption(
              context,
              AppLocalizations.of(context)!.larvalStage4To6,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Larva4To6Screen()),
              ),
            ),
            _buildBiologyOption(
              context,
              AppLocalizations.of(context)!.egg,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BiologyDetailScreen(
                        title: AppLocalizations.of(context)!.egg)),
              ),
            ),
            _buildBiologyOption(
              context,
              AppLocalizations.of(context)!.larva,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BiologyDetailScreen(
                        title: AppLocalizations.of(context)!.larva)),
              ),
            ),
            _buildBiologyOption(
              context,
              AppLocalizations.of(context)!.pupa,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BiologyDetailScreen(
                        title: AppLocalizations.of(context)!.pupa)),
              ),
            ),
            _buildBiologyOption(
              context,
              AppLocalizations.of(context)!.adult,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BiologyDetailScreen(
                        title: AppLocalizations.of(context)!.adult)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiologyOption(
      BuildContext context, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 18, color: Colors.purple.shade300),
        onTap: onTap,
      ),
    );
  }
}

class BiologyDetailScreen extends StatelessWidget {
  final String title;

  const BiologyDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 80, color: Colors.purple.shade200),
            const SizedBox(height: 20),
            Text(
              "Details for $title\nwill be added here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
