import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../utils/app_config.dart';
import '../../features/auth/domain/repositories/session_repository.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio dio;

  ApiClient(SessionRepository sessionRepository)
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onRequest: (options, handler) async {
          final token = await sessionRepository.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final message = _getErrorMessage(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: ServerException(message),
            ),
          );
        },
      ),
    );

    // Bypass SSL certificate validation for debugging common Android/OnRender issues
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // Optional: Add logging interceptor in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  String _getErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      } else if (data is Map && data.containsKey('error')) {
        return data['error'];
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet.";
      case DioExceptionType.connectionError:
        return "Connection error. Ensure the app has internet permissions and the server is reachable.";
      case DioExceptionType.badResponse:
        return "Server error (${e.response?.statusCode}). Please try again later.";
      default:
        return e.message ?? "Something went wrong. Please try again.";
    }
  }
}
