import 'package:flutter/material.dart';

class Larva1To3Screen extends StatelessWidget {
  const Larva1To3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: const Text(
          "Larval growth stage: 1-3 instars",
          style: TextStyle(
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(
                      "The adult female moth lays 100-200 eggs on the leaves."),
                  _buildBulletPoint(
                      "The eggs are covered in cream coloured protective scales. In 3-4 days neonates emerge from eggs and complete their life cycle in 36-42 days."),
                  _buildBulletPoint(
                      "After hatching, the young caterpillars feed superficially on the leaves by scrapping and it results in appearance of semi-transparent white patches on the leaves."),
                  _buildBulletPoint(
                      "Young caterpillars move to the new plants by spinning silken thread."),
                  _buildBulletPoint(
                      "Caterpillars prefer to feed in leaf whorls of young plants and feed more actively during night time."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: Colors.purple.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

