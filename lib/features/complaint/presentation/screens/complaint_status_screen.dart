import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' show HttpClient;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/complaint.dart';
import '../cubits/complaint_detail_cubit.dart';
import '../cubits/complaint_detail_state.dart';
import '../widgets/status_stepper.dart';

class ComplaintStatusScreen extends StatelessWidget {
  final Complaint complaint;

  const ComplaintStatusScreen({
    super.key,
    required this.complaint,
  });

  // ── Status helpers ─────────────────────────────────────────────────────────

  static Color _statusColor(String status) {
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
      default:
        return const Color(0xFF3B82F6);
    }
  }

  static IconData _statusIcon(String status) {
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

  String _displayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'manual_review':  return 'Manual Review';
      case 'in_progress':    return 'In Progress';
      case 'under review':   return 'Under Review';
      default:
        return status
            .split(' ')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  String _formatDate(BuildContext context, DateTime date) =>
      MaterialLocalizations.of(context).formatMediumDate(date);

  bool _hasValidCoordinates(double lat, double lng) =>
      lat.isFinite && lng.isFinite && (lat != 0.0 || lng != 0.0);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<ComplaintDetailCubit>()
        ..loadFromComplaint(complaint)
        ..refreshFromUserComplaints(complaint.id),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
        appBar: CustomAppBar(
          title: l10n.complaintDetails,
          showBackButton: true,
          showThemeToggle: true,
          showNotification: false,
        ),
        body: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          builder: (context, state) {
            if (state is ComplaintDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF005C45)),
              );
            }
            if (state is ComplaintDetailError) {
              return _ErrorView(message: state.message);
            }
            if (state is ComplaintDetailLoaded) {
              final c          = state.complaint;
              final statusColor = _statusColor(c.status);
              final hasLocation = _hasValidCoordinates(c.latitude, c.longitude);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero header card ─────────────────────────────────
                    _HeroCard(
                      complaint: c,
                      statusColor: statusColor,
                      statusIcon: _statusIcon(c.status),
                      displayStatus: _displayStatus(c.status),
                      isDark: isDark,
                      l10n: l10n,
                      formatDate: _formatDate,
                    ),
                    const SizedBox(height: 20),

                    // ── Status stepper ───────────────────────────────────
                    _SectionLabel(label: 'Progress', isDark: isDark),
                    const SizedBox(height: 10),
                    _Card(
                      isDark: isDark,
                      child: StatusStepper(status: c.status),
                    ),
                    const SizedBox(height: 20),

                    // ── Description ──────────────────────────────────────
                    _SectionLabel(label: l10n.issueDescription, isDark: isDark),
                    const SizedBox(height: 10),
                    _Card(
                      isDark: isDark,
                      child: Text(
                        c.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: isDark ? Colors.white70 : const Color(0xFF444455),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Photos ───────────────────────────────────────────
                    if (c.images.isNotEmpty) ...[
                      _SectionLabel(label: l10n.photos, isDark: isDark),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: c.images.length,
                          itemBuilder: (context, i) => _PhotoTile(
                            imageUrl: c.images[i],
                            isDark: isDark,
                            onTap: () =>
                                _showFullScreenImage(context, c.images[i]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Location ─────────────────────────────────────────
                    if (hasLocation) ...[
                      _SectionLabel(
                          label: l10n.locationDetails, isDark: isDark),
                      const SizedBox(height: 10),
                      _Card(
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Coords row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: Color(0xFFEF4444)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${c.latitude.toStringAsFixed(6)}, '
                                      '${c.longitude.toStringAsFixed(6)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF444455),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Map
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter:
                                        LatLng(c.latitude, c.longitude),
                                    initialZoom: 15.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                      fallbackUrl:
                                          'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                                      userAgentPackageName:
                                          'com.cityvoice.complaints',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(
                                              c.latitude, c.longitude),
                                          width: 44,
                                          height: 44,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFEF4444)
                                                  .withOpacity(0.20),
                                            ),
                                            child: const Icon(
                                              Icons.location_on_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 36,
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
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Hero Card
// ════════════════════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.complaint,
    required this.statusColor,
    required this.statusIcon,
    required this.displayStatus,
    required this.isDark,
    required this.l10n,
    required this.formatDate,
  });

  final Complaint complaint;
  final Color statusColor;
  final IconData statusIcon;
  final String displayStatus;
  final bool isDark;
  final AppLocalizations l10n;
  final String Function(BuildContext, DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(isDark ? 0.12 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient top bar that reflects status colour
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.4)],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  complaint.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),

                const SizedBox(height: 14),

                // Org + dates meta row
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (complaint.organizationId.isNotEmpty)
                      _MetaChip(
                        icon: Icons.business_rounded,
                        label: complaint.organizationId,
                        isDark: isDark,
                      ),
                    _MetaChip(
                      icon: Icons.calendar_today_rounded,
                      label:
                          '${l10n.submittedOn} ${formatDate(context, complaint.createdAt)}',
                      isDark: isDark,
                    ),
                    if (complaint.status.toLowerCase() == 'resolved' &&
                        complaint.resolvedAt != null)
                      _MetaChip(
                        icon: Icons.check_circle_rounded,
                        label:
                            '${l10n.resolvedOn} ${formatDate(context, complaint.resolvedAt!)}',
                        isDark: isDark,
                        color: const Color(0xFF22C55E),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ??
        (isDark ? Colors.white54 : const Color(0xFF888899));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: c,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Generic card container
// ════════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  const _Card({
    required this.isDark,
    required this.child,
    this.padding,
  });

  final bool isDark;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.20)
                : Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Section label
// ════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF005C45),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Error view
// ════════════════════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Photo tile (unchanged logic, modernized shell)
// ════════════════════════════════════════════════════════════════════════════

class _PhotoTile extends StatefulWidget {
  final String imageUrl;
  final bool isDark;
  final VoidCallback onTap;

  const _PhotoTile({
    Key? key,
    required this.imageUrl,
    required this.isDark,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  int _reloadKey = 0;

  Future<bool> _determineIfExpired(String url) async {
    final parsed = _isPresignedUrlExpired(url);
    if (parsed) return true;
    try {
      final uri    = Uri.parse(url);
      final client = HttpClient()..autoUncompress = true;
      final req    = await client.openUrl('HEAD', uri);
      final resp   = await req.close();
      final code   = resp.statusCode;
      client.close(force: true);
      if (code == 403) return true;
    } catch (e) {
      debugPrint('HEAD check failed: $e');
    }
    return false;
  }

  bool _isPresignedUrlExpired(String url) {
    try {
      final uri    = Uri.parse(url);
      final params = uri.queryParameters;
      if (params.containsKey('X-Amz-Date') &&
          params.containsKey('X-Amz-Expires')) {
        final dateStr    = params['X-Amz-Date']!;
        final expiresStr = params['X-Amz-Expires']!;
        if (dateStr.length >= 15) {
          final dt = DateTime.utc(
            int.parse(dateStr.substring(0, 4)),
            int.parse(dateStr.substring(4, 6)),
            int.parse(dateStr.substring(6, 8)),
            int.parse(dateStr.substring(9, 11)),
            int.parse(dateStr.substring(11, 13)),
            int.parse(dateStr.substring(13, 15)),
          );
          final expires = int.tryParse(expiresStr) ?? 0;
          return DateTime.now().toUtc().isAfter(dt.add(Duration(seconds: expires)));
        }
      }
      if (params.containsKey('Expires')) {
        final expiresUnix = int.tryParse(params['Expires']!);
        if (expiresUnix != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(
              expiresUnix * 1000, isUtc: true);
          return DateTime.now().toUtc().isAfter(expiry);
        }
      }
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 155,
            height: 155,
            color: widget.isDark
                ? const Color(0xFF2C2F3E)
                : Colors.grey.shade100,
            child: CachedNetworkImage(
              key: ValueKey(_reloadKey),
              imageUrl: widget.imageUrl,
              cacheKey: widget.imageUrl.split('?').first,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: widget.isDark
                    ? Colors.white12
                    : Colors.grey.shade300,
                highlightColor: widget.isDark
                    ? Colors.white24
                    : Colors.grey.shade100,
                child: Container(
                    color: widget.isDark
                        ? const Color(0xFF1C1F2E)
                        : Colors.white),
              ),
              errorWidget: (context, url, error) {
                debugPrint('Image error: $error, url: $url');
                return FutureBuilder<bool>(
                  future: _determineIfExpired(widget.imageUrl),
                  builder: (context, snap) {
                    final expired = snap.data ??
                        _isPresignedUrlExpired(widget.imageUrl);
                    return Container(
                      color: widget.isDark
                          ? const Color(0xFF1C1F2E)
                          : Colors.white,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined,
                              size: 30,
                              color: widget.isDark
                                  ? Colors.white38
                                  : Colors.grey.shade400),
                          const SizedBox(height: 6),
                          Text(
                            expired
                                ? 'Link expired'
                                : AppLocalizations.of(context)!
                                    .failedToLoadImage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.isDark
                                  ? Colors.white38
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _reloadKey++),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF005C45)
                                    .withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF005C45),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}