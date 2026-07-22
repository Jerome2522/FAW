import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

/// Decoupled performance-optimized rotating AI Tips Section
class AiTipsSection extends StatefulWidget {
  const AiTipsSection({super.key});

  @override
  State<AiTipsSection> createState() => _AiTipsSectionState();
}

class _AiTipsSectionState extends State<AiTipsSection> {
  final List<String> _aiTips = const [
    "Early FAW detection can reduce crop loss.",
    "Inspect nearby leaves if damage is found.",
    "Check crops regularly during humid weather.",
  ];

  final ValueNotifier<int> _currentTipIndex = ValueNotifier<int>(0);
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _currentTipIndex.value = (_currentTipIndex.value + 1) % _aiTips.length;
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _currentTipIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF58D9A6).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF1E6B52), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FAW AI Tip of the Day",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: const Color(0xFF1E6B52),
                  ),
                ),
                const SizedBox(height: 2),
                ValueListenableBuilder<int>(
                  valueListenable: _currentTipIndex,
                  builder: (context, index, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _aiTips[index],
                        key: ValueKey<int>(index),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
