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
  /// The full complaint object passed from the list (no extra API call needed).
  final Complaint complaint;

  const ComplaintStatusScreen({
    super.key,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<ComplaintDetailCubit>()
        ..loadFromComplaint(complaint)
        ..refreshFromUserComplaints(complaint.id),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
        appBar: CustomAppBar(
          title: l10n.complaintDetails,
          showBackButton: true,
          showThemeToggle: true,
          showNotification: false,
        ),
        body: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          builder: (context, state) {
            if (state is ComplaintDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ComplaintDetailError) {
              return Center(child: Text(state.message));
            } else if (state is ComplaintDetailLoaded) {
              final complaint = state.complaint;
              final hasLocation = _hasValidCoordinates(complaint.latitude, complaint.longitude);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                      _buildSectionContainer(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    complaint.title,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                                _buildStatusBadge(complaint.status, isDark),
                              ],
                            ),
                            if (complaint.organizationId.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.business_outlined,
                                      size: 14, color: isDark ? Colors.white54 : Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      complaint.organizationId,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 13, color: isDark ? Colors.white54 : Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${l10n.submittedOn} ${_formatDate(context, complaint.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            if (complaint.status.toLowerCase() == 'resolved' && complaint.resolvedAt != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 13, color: Color(0xFF22C55E)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${l10n.resolvedOn} ${_formatDate(context, complaint.resolvedAt!)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF22C55E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status Stepper
                      StatusStepper(status: complaint.status),
                      const SizedBox(height: 20),

                      // Issue Description
                      _buildSectionContainer(
                        isDark: isDark,
                        title: l10n.issueDescription,
                        child: Text(
                          complaint.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    if (complaint.images.isNotEmpty) ...[
                      Text(
                        l10n.photos,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(bottom: 4),
                          itemCount: complaint.images.length,
                          itemBuilder: (context, index) {
                            return _buildPhotoPlaceholder(
                                complaint.images[index], context, isDark);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Location — only shown when the API returned coordinates
                    if (hasLocation) ...[
                      Text(
                        l10n.locationDetails,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionContainer(
                        isDark: isDark,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: Color(0xFFC62828)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${l10n.latitude}: ${complaint.latitude.toStringAsFixed(6)}, '
                                    '${l10n.longitude}: ${complaint.longitude.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(complaint.latitude, complaint.longitude),
                                    initialZoom: 15.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                        'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                      fallbackUrl:
                                        'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                                      userAgentPackageName: 'com.cityvoice.complaints',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(complaint.latitude, complaint.longitude),
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Color(0xFFC62828),
                                            size: 40,
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

  Widget _buildSectionContainer({required bool isDark, Widget? child, String? title, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color backgroundColor;
    Color textColor = Colors.black;

    switch (status.toLowerCase()) {
      case 'manual review':
      case 'manual_review':
      case 'under review':
        backgroundColor = const Color(0xFFFFD166);
        break;
      case 'in progress':
      case 'in_progress':
      case 'submitted':
      case 'pending':
        backgroundColor = const Color(0xFFFCD703);
        break;
      case 'resolved':
      case 'completed':
        backgroundColor = const Color(0xFF22C55E);
        textColor = Colors.white;
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        break;
      default:
        backgroundColor = isDark ? Colors.white24 : Colors.grey.shade300;
        textColor = isDark ? Colors.white : Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  bool _hasValidCoordinates(double latitude, double longitude) {
    return latitude.isFinite && longitude.isFinite && (latitude != 0.0 || longitude != 0.0);
  }

  Widget _buildPhotoPlaceholder(String imageUrl, BuildContext context, bool isDark) {
    return _PhotoTile(
      imageUrl: imageUrl,
      isDark: isDark,
      onTap: () => _showFullScreenImage(context, imageUrl),
    );
  }
  

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
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
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatefulWidget {
  final String imageUrl;
  final bool isDark;
  final VoidCallback onTap;

  const _PhotoTile({Key? key, required this.imageUrl, required this.isDark, required this.onTap}) : super(key: key);

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  int _reloadKey = 0;

  Future<bool> _determineIfExpired(String url) async {
    // First check URL-encoded expiry fields
    final parsed = _isPresignedUrlExpired(url);
    if (parsed) return true;

    // If parsing didn't indicate expiry, try a lightweight HEAD request to detect 403.
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      client.autoUncompress = true;
      final req = await client.openUrl('HEAD', uri);
      final resp = await req.close();
      final code = resp.statusCode;
      client.close(force: true);
      if (code == 403) return true;
    } catch (e) {
      // If network check fails, conservatively assume not expired so user can retry.
      debugPrint('HEAD check failed: $e');
    }
    return false;
  }

  bool _isPresignedUrlExpired(String url) {
    try {
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      if (params.containsKey('X-Amz-Date') && params.containsKey('X-Amz-Expires')) {
        final dateStr = params['X-Amz-Date']!; // format: YYYYMMDDTHHMMSSZ
        final expiresStr = params['X-Amz-Expires']!;
        if (dateStr.length >= 15) {
          final year = int.parse(dateStr.substring(0, 4));
          final month = int.parse(dateStr.substring(4, 6));
          final day = int.parse(dateStr.substring(6, 8));
          final hour = int.parse(dateStr.substring(9, 11));
          final minute = int.parse(dateStr.substring(11, 13));
          final second = int.parse(dateStr.substring(13, 15));
          final dt = DateTime.utc(year, month, day, hour, minute, second);
          final expires = int.tryParse(expiresStr) ?? 0;
          final expiry = dt.add(Duration(seconds: expires));
          return DateTime.now().toUtc().isAfter(expiry);
        }
      }
      if (params.containsKey('Expires')) {
        final expiresUnix = int.tryParse(params['Expires']!);
        if (expiresUnix != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(expiresUnix * 1000, isUtc: true);
          return DateTime.now().toUtc().isAfter(expiry);
        }
      }
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // do not assume expired solely from URL; we'll double-check on error
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 150,
            height: 150,
            color: widget.isDark ? const Color(0xFF2C2F3E) : Colors.grey.shade200,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    key: ValueKey(_reloadKey),
                    imageUrl: widget.imageUrl,
                    cacheKey: widget.imageUrl.split('?').first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return Shimmer.fromColors(
                        baseColor: widget.isDark ? Colors.white12 : Colors.grey.shade300,
                        highlightColor: widget.isDark ? Colors.white24 : Colors.grey.shade100,
                        child: Container(color: widget.isDark ? const Color(0xFF1C1F2E) : Colors.white),
                      );
                    },
                    errorWidget: (context, url, error) {
                      debugPrint('Image Load Error: $error, url: $url');
                      return FutureBuilder<bool>(
                        future: _determineIfExpired(widget.imageUrl),
                        builder: (context, snapshot) {
                          final expired = snapshot.data ?? _isPresignedUrlExpired(widget.imageUrl);
                          return Container(
                            color: widget.isDark ? const Color(0xFF1C1F2E) : Colors.white,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_outlined,
                                    size: 36, color: widget.isDark ? Colors.white54 : Colors.grey.shade400),
                                const SizedBox(height: 6),
                                Text(
                                  expired ? 'Image link expired' : AppLocalizations.of(context)!.failedToLoadImage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.isDark ? Colors.white54 : Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() => _reloadKey++);
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ),
                                    if (expired)
                                      SizedBox(
                                        height: 36,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Best-effort: retry will attempt to reload; server-side refresh is required for new presigned URLs.
                                            setState(() => _reloadKey++);
                                          },
                                          child: const Text('Refresh'),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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

