import 'package:flutter/material.dart';

class Larva4To6Screen extends StatelessWidget {
  const Larva4To6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: const Text(
          "Larval growth stage: 4-6 instars",
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
                      "By stage 4-6, it reaches plant whorl and causes maximum damage to the plant and produces ragged holes in the leaves."),
                  _buildBulletPoint(
                      "Feeding on young plants can kill the growing point, resulting in no new leaves or cobs development."),
                  _buildBulletPoint(
                      "Often there are only 1 or 2 caterpillars in each whorl as they become cannibalistic."),
                  _buildBulletPoint(
                      "Large quantities of frass (caterpillar excreta) is seen in the whorl. When this dries, it resembles saw dust."),
                  _buildBulletPoint(
                      "On the older plants, caterpillar bores into the cobs and feeds on the developing kernels (seeds)."),
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

