import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../subpages/lifecycle.dart';
import '../subpages/larva1-3.dart';
import '../subpages/larva4-6.dart';

class BiologyScreen extends StatelessWidget {
  const BiologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEE8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.biology,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBiologyOption(
      BuildContext context, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.science_outlined,
                    size: 20,
                    color: Color(0xFF2D6A4F),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1B4332),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF2D6A4F),
                ),
              ],
            ),
          ),
        ),
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
      backgroundColor: const Color(0xFFE8EEE8),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFF1B4332),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.science_outlined, size: 60, color: Color(0xFF2D6A4F)),
            ),
            const SizedBox(height: 24),
            Text(
              "Details for $title\nwill be added here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1B4332).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
