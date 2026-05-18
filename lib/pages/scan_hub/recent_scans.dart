import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:fawproto/widgets/scale_on_tap.dart';
import 'package:fawproto/services/scan_history_service.dart';
import 'package:fawproto/models/predict_result.dart';
import 'package:fawproto/l10n/app_localizations.dart';
import 'package:fawproto/features/prediction/prediction_page.dart';
import 'package:fawproto/pages/scan_hub/empty_state.dart';

/// Fade + Slide Route Transition Builder
Route _createPremiumRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.05); // slight slide up
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class RecentScansSection extends StatelessWidget {
  final List<ScanHistoryItem> history;
  final VoidCallback onStartScan;
  final VoidCallback onLoadHistory;

  const RecentScansSection({
    super.key,
    required this.history,
    required this.onStartScan,
    required this.onLoadHistory,
  });

  Map<String, dynamic> _getStatusInfo(PredictResult result) {
    final label = result.prediction?.label.toLowerCase() ?? "";
    if (label.contains("healthy")) {
      return {
        "text": "Healthy",
        "emoji": "🟢",
        "color": const Color(0xFF1E5631),
        "bg": const Color(0xFFD1FAE5),
      };
    } else if (label.contains("faw")) {
      return {
        "text": "FAW detected",
        "emoji": "🔴",
        "color": const Color(0xFFB91C1C),
        "bg": const Color(0xFFFEE2E2),
      };
    } else if (label.contains("damage")) {
      return {
        "text": "Crop Damage",
        "emoji": "🟡",
        "color": const Color(0xFFD97706),
        "bg": const Color(0xFFFEF3C7),
      };
    } else {
      return {
        "text": result.prediction?.displayName ?? "Other insect",
        "emoji": "🔵",
        "color": const Color(0xFF2563EB),
        "bg": const Color(0xFFDBEAFE),
      };
    }
  }

  String _getTreatmentSummary(String label) {
    final lower = label.toLowerCase();
    if (lower.contains("healthy")) {
      return "Continue monitoring crops";
    } else if (lower.contains("faw")) {
      return "Immediate inspection recommended";
    } else if (lower.contains("damage")) {
      return "Assess spread and treat";
    } else {
      return "Compare with insect guides";
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min${mins == 1 ? "" : "s"} ago';
    } else if (difference.inHours < 24) {
      final hrs = difference.inHours;
      return '$hrs hour${hrs == 1 ? "" : "s"} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      final days = difference.inDays;
      return '$days day${days == 1 ? "" : "s"} ago';
    }
  }

  Widget _buildEmptyStateCard({required String title, required String subtitle, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000), // Pre-calculated constant hex alpha (0.01 black)
            blurRadius: 15,
            offset: Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.green.shade50),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0x142D6A4F), // Pre-calculated constant hex alpha (0.08 0xFF2D6A4F)
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2D6A4F),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: const Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Recent Visual Scans
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentScans,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B4332),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: history.isEmpty
              ? EmptyHistoryStateCard(
                  onStartScan: onStartScan,
                )
              : SizedBox(
                  height: 236,
                  child: RepaintBoundary(
                    child: ListView.separated(
                      key: const PageStorageKey('scan_hub_recent_scans_list'),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final statusInfo = _getStatusInfo(item.result);
                        final confidenceVal = (item.result.prediction?.confidence ?? 0.0) * 100;
                        final Color statusColor = statusInfo["color"];

                        final String statusLabel = statusInfo["text"];
                        final IconData statusIcon;
                        if (statusLabel.toLowerCase().contains("healthy")) {
                          statusIcon = Icons.check_circle_rounded;
                        } else if (statusLabel.toLowerCase().contains("faw")) {
                          statusIcon = Icons.bug_report_rounded;
                        } else if (statusLabel.toLowerCase().contains("damage")) {
                          statusIcon = Icons.warning_rounded;
                        } else {
                          statusIcon = Icons.search_rounded;
                        }

                        final String treatmentSummary = _getTreatmentSummary(statusLabel);
                        final String timeAgo = _getTimeAgo(item.timestamp);

                        // Defer and optimize image item stateful lifecycle backed by AutomaticKeepAliveClientMixin
                        return RecentScanCard(
                          item: item,
                          index: index,
                          onLoadHistory: onLoadHistory,
                          statusInfo: statusInfo,
                          confidenceVal: confidenceVal,
                          statusColor: statusColor,
                          statusLabel: statusLabel,
                          statusIcon: statusIcon,
                          treatmentSummary: treatmentSummary,
                          timeAgo: timeAgo,
                        );
                      },
                    ),
                  ),
                ),
        ),

        const SizedBox(height: 28),

        // 2. Recent Images Visual Gallery
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentImages,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B4332),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: history.isEmpty
              ? _buildEmptyStateCard(
                  title: "No Images Yet",
                  subtitle: "Your captured field photos will show here.",
                  icon: Icons.image_search_rounded,
                )
              : SizedBox(
                  height: 80,
                  child: RepaintBoundary(
                    child: ListView.separated(
                      key: const PageStorageKey('scan_hub_recent_images_list'),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return RecentImageThumbnail(
                          item: item,
                          onLoadHistory: onLoadHistory,
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Custom high-performance scan card widget equipped with AutomaticKeepAliveClientMixin
/// to cache the decoded texture inside GPU memory and completely eliminate HEVC decoder tear-down lag.
class RecentScanCard extends StatefulWidget {
  final ScanHistoryItem item;
  final int index;
  final VoidCallback onLoadHistory;
  final Map<String, dynamic> statusInfo;
  final double confidenceVal;
  final Color statusColor;
  final String statusLabel;
  final IconData statusIcon;
  final String treatmentSummary;
  final String timeAgo;

  const RecentScanCard({
    super.key,
    required this.item,
    required this.index,
    required this.onLoadHistory,
    required this.statusInfo,
    required this.confidenceVal,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.treatmentSummary,
    required this.timeAgo,
  });

  @override
  State<RecentScanCard> createState() => _RecentScanCardState();
}

class _RecentScanCardState extends State<RecentScanCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + widget.index * 40),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(40 * (1.0 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: SpringOnTap(
        onTap: () async {
          await Navigator.push(
            context,
            _createPremiumRoute(
              PredictionPage(
                image: XFile(widget.item.imagePath),
                initialResult: widget.item.result,
              ),
            ),
          );
          widget.onLoadHistory();
        },
        child: Container(
          width: 154,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000), // Pre-calculated constant hex alpha (0.02 black)
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(widget.item.thumbnailPath ?? widget.item.imagePath),
                        fit: BoxFit.cover,
                        cacheWidth: 150,
                        cacheHeight: 150,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFEEEEEE),
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xA6000000), // Pre-calculated constant hex alpha (0.65 black)
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${widget.confidenceVal.toStringAsFixed(0)}%",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 9.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(widget.statusIcon, color: widget.statusColor, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.statusInfo["text"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: widget.statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            widget.treatmentSummary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFF9CA3AF), size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.timeAgo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom high-performance gallery visual image widget equipped with AutomaticKeepAliveClientMixin
/// to cache the decoded texture inside GPU memory and completely eliminate HEVC decoder tear-down lag.
class RecentImageThumbnail extends StatefulWidget {
  final ScanHistoryItem item;
  final VoidCallback onLoadHistory;

  const RecentImageThumbnail({
    super.key,
    required this.item,
    required this.onLoadHistory,
  });

  @override
  State<RecentImageThumbnail> createState() => _RecentImageThumbnailState();
}

class _RecentImageThumbnailState extends State<RecentImageThumbnail> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SpringOnTap(
      onTap: () async {
        await Navigator.push(
          context,
          _createPremiumRoute(
            PredictionPage(
              image: XFile(widget.item.imagePath),
              initialResult: widget.item.result,
            ),
          ),
        );
        widget.onLoadHistory();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(widget.item.thumbnailPath ?? widget.item.imagePath),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          cacheWidth: 150,
          cacheHeight: 150,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 80,
            height: 80,
            color: const Color(0xFFEEEEEE),
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
