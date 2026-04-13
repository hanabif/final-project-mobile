import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/complaint_model.dart';
import '../models/citizen_analytics_model.dart';

abstract class ComplaintRemoteDataSource {
  Future<void> submitComplaint(ComplaintModel complaint);
  Future<ComplaintModel> getComplaintStatus(String complaintId);
  Future<List<ComplaintModel>> getUserComplaints();
  Future<ComplaintModel> getComplaintDetail(String complaintId);
  Future<CitizenAnalyticsModel> getCitizenAnalytics();
  Future<String> uploadSingleFile(File file);
  Future<List<String>> uploadMultipleFiles(List<File> files);
}

class ComplaintRemoteDataSourceImpl implements ComplaintRemoteDataSource {
  final ApiClient apiClient;

  ComplaintRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> submitComplaint(ComplaintModel complaint) async {
    try {
      final response = await apiClient.dio.post(
        '/complaints',
        data: complaint.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Server error';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to submit complaint: $e');
    }
  }

  @override
  Future<String> uploadSingleFile(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'folder': 'complaints',
      });

      final response = await apiClient.dio.post(
        '/uploads/single',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['file']['url'] as String;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
       final message = e.response?.data['message'] ?? e.message ?? 'Upload error';
       throw Exception(message);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<List<String>> uploadMultipleFiles(List<File> files) async {
    try {
      final List<MultipartFile> multipartFiles = [];
      for (final file in files) {
        multipartFiles.add(await MultipartFile.fromFile(file.path));
      }

      final formData = FormData.fromMap({
        'files': multipartFiles,
        'folder': 'complaints',
      });

      final response = await apiClient.dio.post(
        '/uploads/multiple',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => item['url'] as String).toList();
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
       final message = e.response?.data['message'] ?? e.message ?? 'Upload error';
       throw Exception(message);
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  @override
  Future<ComplaintModel> getComplaintStatus(String complaintId) async {
    try {
      final response = await apiClient.dio.get('/complaints/$complaintId');

      if (response.statusCode == 200) {
        return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Server error';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to get complaint status: $e');
    }
  }

  @override
  Future<List<ComplaintModel>> getUserComplaints() async {
    try {
      final response = await apiClient.dio.get('/complaints/my-complaints');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Server error';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch complaints: $e');
    }
  }

  @override
  Future<ComplaintModel> getComplaintDetail(String complaintId) async {
    try {
      final response = await apiClient.dio.get('/complaints/$complaintId');

      if (response.statusCode == 200) {
        return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Server error';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch complaint detail: $e');
    }
  }

  @override
  Future<CitizenAnalyticsModel> getCitizenAnalytics() async {
    try {
      final response = await apiClient.dio.get('/analytics/citizen');
      if (response.statusCode == 200) {
        return CitizenAnalyticsModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Server error';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }
}
