import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

    return BlocProvider(
      create: (context) =>
          sl<ComplaintDetailCubit>()..loadFromComplaint(complaint),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: CustomAppBar(
          title: l10n.complaintDetails,
          showBackButton: true,
          showThemeToggle: false,
          showNotification: false,
          backgroundColor: const Color(0xFF005C45),
          titleColor: Colors.white,
        ),
        body: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          builder: (context, state) {
            if (state is ComplaintDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ComplaintDetailError) {
              return Center(child: Text(state.message));
            } else if (state is ComplaintDetailLoaded) {
              final complaint = state.complaint;
              final hasLocation = complaint.latitude != 0.0 || complaint.longitude != 0.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildSectionContainer(
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
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildStatusBadge(complaint.status),
                            ],
                          ),
                          if (complaint.organizationId.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.business_outlined,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    complaint.organizationId,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${l10n.submittedOn} ${_formatDate(context, complaint.createdAt)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          if (complaint.status.toLowerCase() == 'resolved' && complaint.resolvedAt != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 13, color: Color(0xFF005C45)),
                                const SizedBox(width: 4),
                                Text(
                                  '${l10n.resolvedOn} ${_formatDate(context, complaint.resolvedAt!)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF005C45),
                                    fontWeight: FontWeight.w500,
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
                      title: l10n.issueDescription,
                      child: Text(
                        complaint.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (complaint.images.isNotEmpty) ...[
                      Text(
                        l10n.photos,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                                complaint.images[index], context);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Location — only shown when the API returned coordinates
                    if (hasLocation) ...[
                      Text(
                        l10n.locationDetails,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Color(0xFFC62828)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${l10n.latitude}: ${complaint.latitude.toStringAsFixed(6)}, '
                                    '${l10n.longitude}: ${complaint.longitude.toStringAsFixed(6)}',
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedNetworkImage(
                                  imageUrl: _buildStaticMapUrl(
                                    complaint.latitude,
                                    complaint.longitude,
                                  ),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF005C45),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: Icon(
                                        Icons.map_outlined,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
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

  Widget _buildSectionContainer({Widget? child, String? title, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
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
        backgroundColor = const Color(0xFF005C45);
        textColor = Colors.white;
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFE76F51);
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.grey.shade300;
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

  String _buildStaticMapUrl(double latitude, double longitude) {
    final lat = latitude.toStringAsFixed(6);
    final lng = longitude.toStringAsFixed(6);
    return 'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=15&size=640x360&markers=$lat,$lng,red-pushpin';
  }

  Widget _buildPhotoPlaceholder(String imageUrl, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, imageUrl),
          child: Container(
            width: 150,
            height: 150,
            color: Colors.grey.shade200,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF005C45),
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        size: 36, color: Colors.grey.shade400),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.failedToLoadImage,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
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

