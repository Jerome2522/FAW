import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../subpages/biologycontrol.dart';
import '../subpages/checmicalcontrol.dart';
import '../subpages/pheromone.dart';
import '../subpages/restrictions.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEE8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.controlMeasures,
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
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.biologicalControl,
              subtitle: AppLocalizations.of(context)!.naturalEnemies,
              icon: Icons.bug_report_outlined,
              color: const Color(0xFF2D6A4F),
              destination: const BiologicalControlScreen(),
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.chemicalControl,
              subtitle: AppLocalizations.of(context)!.pesticidesAndApp,
              icon: Icons.science_outlined,
              color: const Color(0xFFEF4444),
              destination: const ChemicalControlScreen(),
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.pheromoneControl,
              subtitle: AppLocalizations.of(context)!.trapsAndMonitoring,
              icon: Icons.filter_center_focus,
              color: const Color(0xFF9B5DE5),
              destination: const PheromoneControlScreen(),
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.restrictions,
              subtitle: AppLocalizations.of(context)!.safetyIntervals,
              icon: Icons.block,
              color: const Color(0xFFE65C00),
              destination: const RestrictionsScreen(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D6A4F).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Color(0xFF2D6A4F)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
