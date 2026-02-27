import 'package:dio/dio.dart';
import '../utils/app_config.dart';
import '../../features/auth/domain/repositories/session_repository.dart';

/// [ApiClient] now supports attaching an authorization header on every
/// request. The token is obtained from the [SessionRepository].
class ApiClient {
  final Dio dio;

  ApiClient(SessionRepository sessionRepository)
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // try to fetch token and add Authorization header if present
          final token = await sessionRepository.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
