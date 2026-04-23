import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PheromoneControlScreen extends StatelessWidget {
  const PheromoneControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pheromone Control',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: "Pheromone Traps",
              color: Colors.purple.shade700,
              icon: Icons.filter_center_focus,
              items: [
                "The major compound for FAW, S.frugiperda pheromone (Z)-9-Tetradecenylacetate (as major component) was characterized using chemical detectors and biological detector.",
                "The antennal response of adult S.frugiperda males to (Z)-9-Tetradecenylacetate confirmed the physiological response of the antennal neurons to pheromone.",
                "Controlled released dispenser developed at ICAR-NBAIR is effective for over 45 days.",
                "Install pheromone traps @ 4/acre soon after sowing and monitor moth catches.",
                "Install pheromone traps @ 15/acre for mass trapping of the male moths.",
                "Community action for mass trapping will give successful control.",
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("•",
                        style: TextStyle(
                            fontSize: 24, height: 1.2, color: color)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
