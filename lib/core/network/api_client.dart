import 'package:complaint_resolution_app/features/auth/data/models/refresh_token_response.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/app_config.dart';
import '../../features/auth/domain/repositories/session_repository.dart';
import '../error/exceptions.dart';
// Conditional import for HttpClientAdapter
import 'api_client_adapter_stub.dart'
    if (dart.library.io) 'api_client_adapter_io.dart';

class ApiClient {
  final Dio dio;
  final SessionRepository sessionRepository;

  ApiClient(this.sessionRepository)
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 100),
          receiveTimeout: const Duration(seconds: 100),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token logic if marked as no-auth
          if (options.extra['no-auth'] == true) {
            return handler.next(options);
          }

          final token = await sessionRepository.getToken();
          if (token != null && token.isNotEmpty) {
            bool isExpired = false;
            try {
              isExpired = JwtDecoder.isExpired(token);
            } catch (e) {
              // If token is malformed, treat as expired to trigger refresh or re-auth
              isExpired = true;
            }

            if (isExpired) {
              try {
                final refreshToken = await sessionRepository.getRefreshToken();
                if (refreshToken != null && refreshToken.isNotEmpty) {
                  // Use a separate Dio instance or lock to avoid circularity if possible,
                  // but here we just use the same one with a flag or direct call.
                  // For simplicity, we'll try a fresh POST.
                  final response = await dio.post(
                    '/auth/refresh',
                    data: {'refreshToken': refreshToken},
                    // Prevent infinite loop by not running interceptors for refresh
                    options: Options(extra: {'no-auth': true}),
                  );
                  if (response.statusCode == 200) {
                    final newTokens = RefreshTokenResponse.fromJson(
                      response.data,
                    );
                    await sessionRepository.saveToken(newTokens.accessToken);
                    await sessionRepository.saveRefreshToken(
                      newTokens.refreshToken,
                    );
                    options.headers['Authorization'] =
                        'Bearer ${newTokens.accessToken}';
                  } else {
                    await sessionRepository.clearSession();
                  }
                } else {
                  await sessionRepository.clearSession();
                }
              } catch (e) {
                await sessionRepository.clearSession();
              }
            } else {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              final refreshToken = await sessionRepository.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                final response = await dio.post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                  options: Options(extra: {'no-auth': true}),
                );

                if (response.statusCode == 200) {
                  final newTokens = RefreshTokenResponse.fromJson(
                    response.data,
                  );
                  await sessionRepository.saveToken(newTokens.accessToken);
                  await sessionRepository.saveRefreshToken(
                    newTokens.refreshToken,
                  );

                  // Retry the original request
                  final opts = e.requestOptions;
                  opts.headers['Authorization'] =
                      'Bearer ${newTokens.accessToken}';
                  final cloneReq = await dio.fetch(opts);
                  return handler.resolve(cloneReq);
                }
              }
            } on DioException {
              await sessionRepository.clearSession();
              // Pass the original error to be handled by the UI
            }
          }
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

    // Platform-specific adapter configuration
    configureAdapter(dio);

    // Optional: Add logging interceptor in debug mode
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
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
