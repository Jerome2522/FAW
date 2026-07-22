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
            color: Colors.black.withValues(alpha: 0.01),
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
                    color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
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
    final l10n = AppLocalizations.of(context)!;
    final isEgg = title == l10n.egg || title.toLowerCase().contains("egg");
    final isLarva = title == l10n.larva || title.toLowerCase().contains("larva");
    final isPupa = title == l10n.pupa || title.toLowerCase().contains("pupa");
    final isAdult = title == l10n.adult || title.toLowerCase().contains("adult");

    String description = "";
    String durationInfo = "";
    String biologicalDetails = "";
    IconData icon = Icons.science_outlined;
    List<String> managementTips = [];
    List<String> hostPlants = [
      "Maize",
      "Sorghum",
      "Pearl millet",
      "Barnyard millet",
      "Finger millet"
    ];
    String introductionText = "The Fall Armyworm (FAW), Spodoptera frugiperda (J.E. Smith) is a polyphagous pest native to North and South America. It was first recorded in Africa in 2016, subsequently spreading rapidly across Asia. In India, it was first reported in 2018 on maize and quickly spread to almost all maize-growing states.";

    if (isEgg) {
      icon = Icons.egg_rounded;
      durationInfo = "2 - 4 Days";
      description = "Female moth lays eggs in mass, which is often covered with scales. Single female may lay 300-1100 eggs in her lifetime. Egg incubation period ranges from 2-4 days.";
      biologicalDetails = "Appearance: Cluster of cream-colored eggs on a leaf, typically covered with scales from the female's body.";
      managementTips = [
        "Scout the crop regularly for the presence of egg masses and neonates, and destroy them manually.",
        "Release egg parasitoids at weekly intervals when 1-2 adult moths are caught in pheromone traps (3-4 releases of Trichogramma chilonis / T. pretiosum @ 1,00,000 adults/ha or Telenomus remus @ 15,000-20,000 adults/ha).",
        "Spray neem oil @ 3 ml/litre or 5% Neem Seed Kernel Emulsion (NSKE) or azadirachtin 1500 ppm @ 5 ml/l of water to kill eggs and neonates.",
        "Apply one spray of NBAIR BT-25 @ 20 ml/litre if required, one week after the neem spray."
      ];
    } else if (isLarva) {
      icon = Icons.bug_report_rounded;
      durationInfo = "13 - 20 Days";
      description = "Fall armyworm passes through six larval instars and the larval duration is completed in 13-20 days. These larvae are highly cannibalistic in nature; hence, a maximum of 1-2 grown-up larvae are typically found inside a single whorl.";
      biologicalDetails = "Immediately after hatching, gregarious larvae start scraping the leaf surface and make papery windows. As they grow, they move to other plants and enter inside the whorl. Due to excessive feeding, it causes large holes which give a torn appearance. Frass is visible in whorls. Continuous feeding may destroy tassels and cobs.";
      managementTips = [
        "Seed treatment with cyantraniliprole 19.8% + Thiamethoxam 19.8% FS @ 6 ml/kg for crop protection during the first 15-20 days.",
        "Release Bracon brevicornis @ 4000 adults/ha to target mature larvae.",
        "Spray Metarhizium anisopliae (NBAIR Ma-35) (1 × 10⁸ cfu/g) @ 5 gm/litre or aqueous suspension of SpfNPV @ 4 ml/l of water (1.5 × 10¹² POBs/ha) if required.",
        "If infestation exceeds thresholds, spray recommended chemicals:\n• Chlorantraniliprole 18.5 SC @ 80 ml/acre (0.4 ml/litre)\n• Thiamethoxam 12.6% + Lambda cyhalothrin 9.5% ZC @ 0.25 ml/litre\n• Spinetoram 11.7% SC @ 100 ml/acre (0.5 ml/litre)"
      ];
    } else if (isPupa) {
      icon = Icons.hourglass_empty_rounded;
      durationInfo = "7 - 10 Days";
      description = "Pupation generally occurs in the soil, and the pupal duration lasts for 7-10 days.";
      biologicalDetails = "The resting stage where the larva transforms into an adult moth inside a cocoon in the soil.";
      managementTips = [
        "After harvesting, practice deep ploughing to expose pupae to direct sun and predators.",
        "Ensure proper weed management to reduce shelter for pupating larvae."
      ];
    } else if (isAdult) {
      icon = Icons.pest_control_rounded;
      durationInfo = "25 - 33 Days (Egg to Adult)";
      description = "Total developmental period from egg to adult is completed in 25-33 days. Adult moths are active fliers capable of spreading rapidly over large distances.";
      biologicalDetails = "Adult moths resting on a leaf. Single female moth may lay 300-1100 eggs in her lifetime.";
      managementTips = [
        "Install pheromone traps (10 traps/acre) immediately after seedling emergence for monitoring and mass trapping male moths.",
        "Intercrop or alley crop maize with pigeon pea, black gram, or green gram.",
        "Plant 3-4 rows of Napier grass as a trap crop around maize fields.",
        "Practice proper crop management tactics through appropriate dose of fertilizers, manures, and proper irrigation."
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E6B52),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E6B52), size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E6B52).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: const Color(0xFF1E6B52)),
              ),
            ),
            const SizedBox(height: 24),
            // Duration card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Duration / Period",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF1E6B52),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF58D9A6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          durationInfo,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: const Color(0xFF1E6B52),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Overview & Description",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E6B52),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: Colors.grey[800],
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLarva ? "Nature of Damage" : "Appearance & Behavior Details",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E6B52),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    biologicalDetails,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: Colors.grey[800],
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Management Tips Card
            if (managementTips.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Management & Control Tactics",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1E6B52),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...managementTips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(Icons.check_circle_outline_rounded, color: Color(0xFF1E6B52), size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Host Plants Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Host Plants & Impact",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E6B52),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fall armyworm is a highly polyphagous pest, reported to feed on 182 plants belonging to 42 families worldwide.",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hostPlants.map((plant) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6B52).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        plant,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E6B52),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Background Intro Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EFE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Historical Context",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF1E6B52),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    introductionText,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF1E6B52),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


