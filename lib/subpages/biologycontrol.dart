import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BiologicalControlScreen extends StatelessWidget {
  const BiologicalControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Biological Control',
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
              title: "Biological Solutions",
              color: Colors.green.shade700,
              icon: Icons.bug_report_outlined,
              items: [
                "At early crop stage (15-30 days after sowing): Release egg parasitoid. Trichogramma pretiosum @ 3 cards (50000 eggs)/acre - two times at 15 days interval. (Egg cards are available at NBAIR, Hebbal and RCIPMC, Kadugodi, Bangalore and State biocontrol labs).",
                "Metarhizium rileyi (= Nomuraea rileyi) and Metarhizium anisopliae infects several species of Lepidoptera. Spray M. rileyi @ 2-3 grams per liter of water (It is available at UAS, Dharwad) or M. anisopliae @ 3 grams per liter (it is available in all state biocontrol labs).",
                "Application of Bt insecticide @ 2 ml/litre. Give 2-3 sprays at 10 days interval.",
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Note: Spray should be directed into the leaf whorls.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
