import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../models/complaint_model.dart';
import '../models/citizen_analytics_model.dart';

abstract class ComplaintRemoteDataSource {
  Future<String> submitComplaint(ComplaintModel complaint);
  Future<ComplaintModel> getComplaintStatus(String complaintId);
  Future<List<ComplaintModel>> getUserComplaints();
  Future<ComplaintModel> getComplaintDetail(String complaintId);
  Future<CitizenAnalyticsModel> getCitizenAnalytics();
  Future<String> uploadSingleFile(XFile file);
  Future<List<String>> uploadMultipleFiles(List<XFile> files);
  Future<void> deleteUploadedFile(String fileKey);
  Future<void> moderateComplaint(String complaintId);
  Future<List<Map<String, dynamic>>> getOrganizations();
}

class ComplaintRemoteDataSourceImpl implements ComplaintRemoteDataSource {
  final ApiClient apiClient;

  ComplaintRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> submitComplaint(ComplaintModel complaint) async {
    try {
      final response = await apiClient.dio.post(
        '/complaints',
        data: complaint.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final complaintData = data['complaint'] is Map ? data['complaint'] as Map<String, dynamic> : data;
        return complaintData['id']?.toString() ?? complaintData['_id']?.toString() ?? '';
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
      throw Exception('Failed to submit complaint: $e');
    }
  }

  @override
  Future<String> uploadSingleFile(XFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name,
        ),
        'folder': 'complaints',
      });

      final response = await apiClient.dio.post(
        '/uploads',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('urls') && (data['urls'] as List).isNotEmpty) {
          return data['urls'][0] as String;
        } else if (data.containsKey('file')) {
          return data['file']['url'] as String;
        } else if (data.containsKey('files') && (data['files'] as List).isNotEmpty) {
          return data['files'][0]['url'] as String;
        }
        throw Exception('Unexpected response format');
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
  Future<List<String>> uploadMultipleFiles(List<XFile> files) async {
    try {
      final List<MultipartFile> multipartFiles = [];
      for (final file in files) {
        multipartFiles.add(
          MultipartFile.fromBytes(
            await file.readAsBytes(),
            filename: file.name,
          ),
        );
      }

      final formData = FormData.fromMap({
        'files': multipartFiles,
        'folder': 'complaints',
      });

      final response = await apiClient.dio.post(
        '/uploads',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('urls')) {
          return (data['urls'] as List).cast<String>();
        } else if (data.containsKey('files')) {
          return (data['files'] as List).map((item) => item['url'] as String).toList();
        }
        throw Exception('Unexpected response format');
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

  @override
  Future<void> deleteUploadedFile(String fileKey) async {
    try {
      final response = await apiClient.dio.delete(
        '/uploads',
        data: {'fileKey': fileKey},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Delete error';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  @override
  Future<void> moderateComplaint(String complaintId) async {
    try {
      final response = await apiClient.dio.post(
        '/ai/moderate',
        data: {'complaintId': complaintId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('AI moderation failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message ?? 'Moderation error';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to moderate complaint: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrganizations() async {
    try {
      final response = await apiClient.dio.get('/organizations/citizen-list');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
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
      throw Exception('Failed to fetch organizations: $e');
    }
  }
}
