import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/complaint_model.dart';

abstract class ComplaintRemoteDataSource {
  Future<void> submitComplaint(ComplaintModel complaint);
  Future<ComplaintModel> getComplaintStatus(String complaintId);
}

class ComplaintRemoteDataSourceImpl implements ComplaintRemoteDataSource {
  final ApiClient apiClient;

  ComplaintRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> submitComplaint(ComplaintModel complaint) async {
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
        throw Exception('Server error: \${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.unknown) {
        throw Exception('Network error: \${e.message}');
      } else if (e.response != null) {
        throw Exception('Server error: \${e.response?.statusCode} - \${e.response?.statusMessage}');
      } else {
        throw Exception('Unknown error occurred');
      }
    } catch (e) {
      throw Exception('Failed to submit complaint: \$e');
    }
  }

  @override
  Future<ComplaintModel> getComplaintStatus(String complaintId) async {
    try {
      final response = await apiClient.dio.get('/complaints/\$complaintId');

      if (response.statusCode == 200) {
        return ComplaintModel.fromJson(response.data);
      } else {
         throw Exception('Server error: \${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.unknown) {
        throw Exception('Network error: \${e.message}');
      } else if (e.response != null) {
        throw Exception('Server error: \${e.response?.statusCode} - \${e.response?.statusMessage}');
      } else {
        throw Exception('Unknown error occurred');
      }
    } catch (e) {
      throw Exception('Failed to get complaint status: \$e');
    }
  }
}
