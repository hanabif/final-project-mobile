import 'package:flutter/material.dart';
import '../../domain/entities/complaint.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  // ── Status helpers ─────────────────────────────────────────────────────────

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'in progress':
      case 'in_progress':
      case 'manual review':
      case 'manual_review':
      case 'under review':
        return const Color(0xFFF59E0B);
      case 'submitted':
      case 'pending':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  static IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'in progress':
      case 'in_progress':
      case 'manual review':
      case 'manual_review':
      case 'under review':
        return Icons.autorenew_rounded;
      default:
        return Icons.upload_file_rounded;
    }
  }

  String _getLogoPath(String organization) {
    final org = organization.toLowerCase();
    if (org.contains('electric')) return 'assets/images/Property 1=electric.png';
    if (org.contains('water'))    return 'assets/images/Property 1=water.png';
    if (org.contains('telecom'))  return 'assets/images/logo (1).png';
    if (org.contains('road') || org.contains('transport'))
      return 'assets/images/Property 1=road.png';
    return 'assets/images/logo (1).png';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final status  = complaint.status;
    final color   = statusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.28)
                  : color.withOpacity(0.10),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent stripe ────────────────────────────────────────
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // ── Card body ─────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: logo + meta + arrow ──────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              _getLogoPath(complaint.organizationId),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.business_rounded,
                                size: 22,
                                color: isDark ? Colors.white38 : Colors.black26,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Title + org + date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business_rounded,
                                      size: 11,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        complaint.organizationId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Arrow
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: isDark
                                ? Colors.white.withOpacity(0.24)
                                : Colors.black.withOpacity(0.20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Divider ───────────────────────────────────────────
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.05),
                      ),

                      const SizedBox(height: 10),

                      // ── Bottom row: status badge + date ───────────────────
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(isDark ? 0.18 : 0.10),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon(status),
                                    size: 11, color: color),
                                const SizedBox(width: 5),
                                Text(
                                  _displayStatus(status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: isDark
                                    ? Colors.white.withOpacity(0.30)
                                    : Colors.black.withOpacity(0.30),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(complaint.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
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
    );
  }

  /// Normalize raw status strings to a clean display label.
  String _displayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'manual_review':   return 'Manual Review';
      case 'in_progress':     return 'In Progress';
      case 'under review':    return 'Under Review';
      default:
        // Capitalize first letter of each word
        return status
            .split(' ')
            .map((w) => w.isEmpty
                ? w
                : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }
}