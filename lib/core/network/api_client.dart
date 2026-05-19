import 'package:flutter/foundation.dart';
import 'package:complaint_resolution_app/features/auth/data/models/refresh_token_response.dart';
import 'package:dio/dio.dart';
import '../utils/app_config.dart';
import '../utils/navigator_key.dart';
import '../utils/token_refresh_util.dart';
import '../../features/auth/domain/repositories/session_repository.dart';
import '../routes/route_names.dart';
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
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token logic if marked as no-auth (for public endpoints like login/register)
          if (options.extra['no-auth'] == true) {
            return handler.next(options);
          }

          final token = await sessionRepository.getToken();
          if (token != null && token.isNotEmpty) {
            // Check if token is expired
            if (TokenRefreshUtil.isTokenExpired(token)) {
              // Token is expired, attempt to refresh
              try {
                final refreshToken = await sessionRepository.getRefreshToken();
                if (refreshToken != null && refreshToken.isNotEmpty) {
                  final response = await dio.post(
                    '/auth/refresh',
                    data: {'refreshToken': refreshToken},
                    // Prevent infinite loop by not running interceptors for refresh
                    options: Options(extra: {'no-auth': true}),
                  );
                  if (response.statusCode == 200) {
                    final newTokens = RefreshTokenResponse.fromJson(
                      response.data as Map<String, dynamic>,
                    );
                    await sessionRepository.saveToken(newTokens.accessToken);
                    await sessionRepository.saveRefreshToken(
                      newTokens.refreshToken,
                    );
                    options.headers['Authorization'] =
                        'Bearer ${newTokens.accessToken}';
                  } else {
                    // Refresh failed, clear session and redirect to login
                    await sessionRepository.clearSession();
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      RouteNames.login,
                      (route) => false,
                    );
                  }
                } else {
                  // No refresh token available, clear session
                  await sessionRepository.clearSession();
                }
              } catch (e) {
                // Refresh error, clear session and redirect
                debugPrint('Token refresh error: $e');
                await sessionRepository.clearSession();
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  RouteNames.login,
                  (route) => false,
                );
              }
            } else {
              // Token is still valid, attach it to request
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          bool isTokenExpiredMsg = false;
          if (e.response != null && e.response?.data != null) {
            final data = e.response?.data;
            if (data is Map && data['message'] == 'Access token expired') {
              isTokenExpiredMsg = true;
            }
          }

          if (e.response?.statusCode == 401 || isTokenExpiredMsg) {
            debugPrint('Received 401 or token expired message - attempting token refresh');
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
                    response.data as Map<String, dynamic>,
                  );
                  await sessionRepository.saveToken(newTokens.accessToken);
                  await sessionRepository.saveRefreshToken(
                    newTokens.refreshToken,
                  );

                  // Retry the original request with new token
                  final opts = e.requestOptions;
                  opts.headers['Authorization'] =
                      'Bearer ${newTokens.accessToken}';
                  final cloneReq = await dio.fetch(opts);
                  return handler.resolve(cloneReq);
                }
              }
              // Refresh failed or no refresh token, clear session
              await sessionRepository.clearSession();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                RouteNames.login,
                (route) => false,
              );
            } on DioException catch (refreshError) {
              debugPrint('Token refresh failed: ${refreshError.message}');
              await sessionRepository.clearSession();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                RouteNames.login,
                (route) => false,
              );
            } catch (e) {
              debugPrint('Unexpected error during token refresh: $e');
              await sessionRepository.clearSession();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                RouteNames.login,
                (route) => false,
              );
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
