import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../cubits/complaint_detail_cubit.dart';
import '../cubits/complaint_detail_state.dart';
import '../widgets/status_stepper.dart';

class ComplaintStatusScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintStatusScreen({
    super.key,
    required this.complaintId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ComplaintDetailCubit>()..fetchComplaintDetail(complaintId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Complaint Details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          builder: (context, state) {
            if (state is ComplaintDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ComplaintDetailError) {
              return Center(child: Text(state.message));
            } else if (state is ComplaintDetailLoaded) {
              final complaint = state.complaint;
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
                              _buildUrgencyTag(complaint.priority),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            complaint.category,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status Stepper
                    StatusStepper(status: complaint.status),
                    const SizedBox(height: 20),

                    // Issue Description
                    _buildSectionContainer(
                      title: 'Issue Description',
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
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: complaint.images.length,
                          itemBuilder: (context, index) {
                            return _buildPhotoPlaceholder(complaint.images[index], context);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Map Location
                    const Text(
                      'Location Details',
                      style: TextStyle(
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
                              const Icon(Icons.location_on, color: Color(0xFFC62828)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lat: ${complaint.latitude.toStringAsFixed(6)}, Lng: ${complaint.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Icon(Icons.map_outlined, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildUrgencyTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC62828),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(String imageUrl, BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            // Log error or handle gracefully
          },
        ),
      ),
      child: Stack(
        children: [
          // Fallback if image fails to load
          Positioned.fill(
            child: FutureBuilder(
              future: precacheImage(NetworkImage(imageUrl), context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

