import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.controlMeasures,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.biologicalControl,
              subtitle: AppLocalizations.of(context)!.naturalEnemies,
              icon: Icons.bug_report_outlined,
              color: Colors.green.shade700,
              destination: const BiologicalControlScreen(),
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.chemicalControl,
              subtitle: AppLocalizations.of(context)!.pesticidesAndApp,
              icon: Icons.science_outlined,
              color: Colors.red.shade700,
              destination: const ChemicalControlScreen(),
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.pheromoneControl,
              subtitle: AppLocalizations.of(context)!.trapsAndMonitoring,
              icon: Icons.filter_center_focus,
              color: Colors.purple.shade700,
              destination: const PheromoneControlScreen(),
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              title: AppLocalizations.of(context)!.restrictions,
              subtitle: AppLocalizations.of(context)!.safetyIntervals,
              icon: Icons.block,
              color: Colors.orange.shade900,
              destination: const RestrictionsScreen(),
            ),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
