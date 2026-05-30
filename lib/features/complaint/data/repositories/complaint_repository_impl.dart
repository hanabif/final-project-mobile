import 'package:complaint_resolution_app/core/network/network_info.dart';
import 'package:complaint_resolution_app/features/complaint/data/datasources/complaint_local_data_source.dart';
import 'package:complaint_resolution_app/features/complaint/data/models/organization_model.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/organization.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_submission_result.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';
import '../models/complaint_model.dart';
import '../models/citizen_analytics_model.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;
  final ComplaintLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ComplaintRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<ComplaintSubmissionResult> submitComplaint(Complaint complaint) async {
    if (await networkInfo.isConnected) {
      try {
        final complaintId = await _submitComplaintOnline(complaint);
        return ComplaintSubmissionResult(
          complaintId: complaintId,
          isQueued: false,
          message: 'Complaint submitted successfully!',
        );
      } catch (e) {
        if (_isNetworkFailure(e)) {
          await localDataSource.cacheComplaint(ComplaintModel.fromEntity(complaint));
          return const ComplaintSubmissionResult(
            isQueued: true,
            message:
                'No internet connection. Your complaint was saved and will be submitted automatically when you are back online.',
          );
        }
        rethrow;
      }
    } else {
      final complaintModel = ComplaintModel.fromEntity(complaint);
      await localDataSource.cacheComplaint(complaintModel);
      return const ComplaintSubmissionResult(
        isQueued: true,
        message:
            'No internet connection. Your complaint was saved and will be submitted automatically when you are back online.',
      );
    }
  }

  @override
  Future<String> getComplaintStatus(String complaintId) async {
    try {
      final complaintModel = await remoteDataSource.getComplaintStatus(
        complaintId,
      );
      return complaintModel.status;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Complaint>> getUserComplaints({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final localComplaints = await localDataSource.getComplaints();
      if (localComplaints.isNotEmpty && _hasUsableComplaintCache(localComplaints)) {
        return localComplaints;
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final remoteComplaints = await remoteDataSource.getUserComplaints();
        await localDataSource.cacheComplaints(remoteComplaints);
        return remoteComplaints;
      } catch (e) {
        rethrow;
      }
    }

    final localComplaints = await localDataSource.getComplaints();
    if (localComplaints.isNotEmpty) {
      return localComplaints;
    }

    return localComplaints;
  }

  bool _hasUsableComplaintCache(List<Complaint> complaints) {
    return complaints.any((complaint) {
      final status = complaint.status.trim().toLowerCase();
      return status.isNotEmpty && status != 'pending';
    });
  }

  @override
  Future<Complaint> getComplaintDetail(String complaintId) async {
    try {
      final model = await remoteDataSource.getComplaintDetail(complaintId);
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CitizenAnalyticsModel> getCitizenAnalytics({bool forceRefresh = false}) async {
    try {
      final analytics = await remoteDataSource.getCitizenAnalytics();
      await localDataSource.cacheCitizenAnalytics(analytics);
      return analytics;
    } catch (e) {
      final cachedAnalytics = await localDataSource.getCachedCitizenAnalytics();
      if (cachedAnalytics != null) {
        return cachedAnalytics;
      }
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadImages(List<XFile> files) async {
    try {
      if (files.isEmpty) return [];
      if (files.length == 1) {
        final url = await remoteDataSource.uploadSingleFile(files.first);
        return [url];
      } else {
        return await remoteDataSource.uploadMultipleFiles(files);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUploadedFile(String fileKey) async {
    try {
      await remoteDataSource.deleteUploadedFile(fileKey);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> moderateComplaint(String complaintId) async {
    try {
      await remoteDataSource.moderateComplaint(complaintId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncPendingComplaints() async {
    if (!await networkInfo.isConnected) {
      return;
    }

    final queuedComplaints = await localDataSource.getQueuedComplaints();
    if (queuedComplaints.isEmpty) {
      return;
    }

    for (final complaint in queuedComplaints) {
      try {
        final complaintId = await _submitComplaintOnline(complaint);
        if (complaintId.isNotEmpty) {
          await localDataSource.removeQueuedComplaint(complaint.id);
        }
      } catch (e) {
        if (_isNetworkFailure(e)) {
          return;
        }
      }
    }
  }

  Future<String> _submitComplaintOnline(Complaint complaint) async {
    final complaintModel = await _buildComplaintModelForSubmission(complaint);
    final complaintId = await remoteDataSource.submitComplaint(complaintModel);
    try {
      await moderateComplaint(complaintId);
    } catch (_) {
      // Moderation is best-effort; a network hiccup here should not duplicate the complaint.
    }
    return complaintId;
  }

  Future<ComplaintModel> _buildComplaintModelForSubmission(Complaint complaint) async {
    final uploadableFiles = complaint.images
        .where((path) => path.trim().isNotEmpty && !_looksLikeRemoteUrl(path))
        .map((path) => XFile(path))
        .toList();

    List<String> uploadedUrls = [];
    if (uploadableFiles.isNotEmpty) {
      uploadedUrls = await uploadImages(uploadableFiles);
    }

    final mergedImages = uploadedUrls.isNotEmpty ? uploadedUrls : complaint.images;
    final imageUrl = uploadedUrls.isNotEmpty ? uploadedUrls.first : complaint.imageUrl;

    return ComplaintModel.fromEntity(
      Complaint(
        id: complaint.id,
        title: complaint.title,
        description: complaint.description,
        imageUrl: imageUrl,
        images: mergedImages,
        latitude: complaint.latitude,
        longitude: complaint.longitude,
        organizationId: complaint.organizationId,
        status: complaint.status,
        category: complaint.category,
        priority: complaint.priority,
        department: complaint.department,
        createdAt: complaint.createdAt,
        updatedAt: complaint.updatedAt,
        resolvedAt: complaint.resolvedAt,
        history: complaint.history,
      ),
    );
  }

  bool _looksLikeRemoteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  bool _isNetworkFailure(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('network error') ||
        message.contains('socketexception') ||
        message.contains('connection timed out') ||
        message.contains('connection error') ||
        message.contains('failed to upload image') ||
        message.contains('failed to upload images') ||
        message.contains('upload error');
  }

  @override
  Future<List<Organization>> getOrganizations({bool forceRefresh = false}) async {
    // Skip cache if forceRefresh is true
    if (!forceRefresh) {
      final localOrgs = await localDataSource.getOrganizations();
      if (localOrgs.isNotEmpty) {
        return localOrgs;
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final remoteOrgs = await remoteDataSource.getOrganizations();
        final orgModels = remoteOrgs
            .map((org) => OrganizationModel.fromJson(org))
            .toList();
        await localDataSource.cacheOrganizations(orgModels);
        return orgModels;
      } catch (e) {
        rethrow;
      }
    } else {
      final localOrgs = await localDataSource.getOrganizations();
      return localOrgs;
    }
  }
}
