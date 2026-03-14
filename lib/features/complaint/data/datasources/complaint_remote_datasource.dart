// import 'dart:io';
// import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/complaint_model.dart';

abstract class ComplaintRemoteDataSource {
  Future<void> submitComplaint(ComplaintModel complaint);
  Future<ComplaintModel> getComplaintStatus(String complaintId);
  Future<List<ComplaintModel>> getUserComplaints();
  Future<ComplaintModel> getComplaintDetail(String complaintId);
}

class ComplaintRemoteDataSourceImpl implements ComplaintRemoteDataSource {
  final ApiClient apiClient;

  ComplaintRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> submitComplaint(ComplaintModel complaint) async {
    // Artificial delay to simulate network request
    await Future.delayed(const Duration(seconds: 2));

    // For testing, always succeed
    return;
    
    /*
    try {
      final formData = FormData.fromMap({
        'title': complaint.title,
        'description': complaint.description,
        'latitude': complaint.latitude,
        'longitude': complaint.longitude,
        'organizationId': complaint.organizationId,
      });

      if (complaint.imageUrl != null && complaint.imageUrl!.isNotEmpty) {
        final file = File(complaint.imageUrl!);
        if (await file.exists()) {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(
              complaint.imageUrl!,
              filename: complaint.imageUrl!.split('/').last,
            ),
          ));
        }
      }

      final response = await apiClient.dio.post(
        '/complaints',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.unknown) {
        throw Exception('Network error: ${e.message}');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      } else {
        throw Exception('Unknown error occurred');
      }
    } catch (e) {
      throw Exception('Failed to submit complaint: $e');
    }
    */
  }

  @override
  Future<ComplaintModel> getComplaintStatus(String complaintId) async {
    // Artificial delay
    await Future.delayed(const Duration(seconds: 1));

    // Return dummy status for testing
    return ComplaintModel(
      id: complaintId,
      title: 'Mock Complaint',
      description: 'This is a mock description for testing.',
      imageUrl: '',
      latitude: 0.0,
      longitude: 0.0,
      organizationId: 'Ethiopian Electric Utility',
      status: 'In Progress',
      createdAt: DateTime.now(),
    );

    /*
    try {
      final response = await apiClient.dio.get('/complaints/$complaintId');

      if (response.statusCode == 200) {
        return ComplaintModel.fromJson(response.data);
      } else {
         throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.unknown) {
        throw Exception('Network error: ${e.message}');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      } else {
        throw Exception('Unknown error occurred');
      }
    } catch (e) {
      throw Exception('Failed to get complaint status: $e');
    }
    */
  }

  @override
  Future<List<ComplaintModel>> getUserComplaints() async {
    // Artificial delay to simulate network request
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data for testing
    return [
      ComplaintModel(
        id: 'complaint-001',
        title: 'Power Outage',
        description: 'No electricity in the neighborhood since yesterday.',
        imageUrl: null,
        latitude: 9.0248,
        longitude: 38.7469,
        organizationId: 'Ethiopian Electric Utility',
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ComplaintModel(
        id: 'complaint-002',
        title: 'Water Supply Issue',
        description: 'Water has been cut off for three days.',
        imageUrl: null,
        latitude: 9.0300,
        longitude: 38.7500,
        organizationId: 'Addis Ababa Water Authority',
        status: 'In Progress',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    /*
    try {
      final response = await apiClient.dio.get('/complaints');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server error: \${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        throw Exception('Network error: \${e.message}');
      } else if (e.response != null) {
        throw Exception(
            'Server error: \${e.response?.statusCode} - \${e.response?.statusMessage}');
      } else {
        throw Exception('Unknown error occurred');
      }
    } catch (e) {
      throw Exception('Failed to fetch complaints: \$e');
    }
    */
  }

  @override
  Future<ComplaintModel> getComplaintDetail(String complaintId) async {
    // Artificial delay to simulate network request
    await Future.delayed(const Duration(seconds: 1));

    // Return mock detail for testing
    return ComplaintModel(
      id: complaintId,
      title: 'Mock Complaint Detail',
      description: 'Detailed description for complaint $complaintId.',
      imageUrl: null,
      latitude: 9.0248,
      longitude: 38.7469,
      organizationId: 'Ethiopian Electric Utility',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    );

    /*
    try {
      final response = await apiClient.dio.get('/complaints/\$complaintId');

      if (response.statusCode == 200) {
        return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server error: \${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        throw Exception('Network error: \${e.message}');
      } else if (e.response != null) {
        throw Exception(
            'Server error: \${e.response?.statusCode} - \${e.response?.statusMessage}');
      } else {
        throw Exception('Unknown error occurred');
      }
    } catch (e) {
      throw Exception('Failed to fetch complaint detail: \$e');
    }
    */
  }
}
