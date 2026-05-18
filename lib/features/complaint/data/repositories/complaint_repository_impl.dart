import 'package:complaint_resolution_app/core/network/network_info.dart';
import 'package:complaint_resolution_app/features/complaint/data/datasources/complaint_local_data_source.dart';
import 'package:complaint_resolution_app/features/complaint/data/models/organization_model.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/organization.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/complaint.dart';
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
  Future<String> submitComplaint(Complaint complaint) async {
    if (await networkInfo.isConnected) {
      try {
        final complaintModel = ComplaintModel.fromEntity(complaint);
        return await remoteDataSource.submitComplaint(complaintModel);
      } catch (e) {
        rethrow;
      }
    } else {
      final complaintModel = ComplaintModel.fromEntity(complaint);
      await localDataSource.cacheComplaint(complaintModel);
      return 'Complaint cached and will be submitted when online.';
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
      return await remoteDataSource.getCitizenAnalytics();
    } catch (e) {
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
