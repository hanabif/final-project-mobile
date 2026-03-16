import 'package:complaint_resolution_app/features/auth/presentation/cubit/password_reset/password_reset_cubit.dart';
import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'core/utils/secure_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/repositories/session_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/session_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/verify_code_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/save_token_usecase.dart';
import 'features/auth/domain/usecases/get_token_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/is_session_valid_usecase.dart';
import 'features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'features/notification/presentation/services/firebase_notification_service.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Notifications
  sl.registerLazySingleton<FirebaseNotificationService>(
    () => FirebaseNotificationService(),
  );


  // Auth - Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Auth - Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SaveTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => IsSessionValidUseCase(sl()));

  // Auth - Presentation
  sl.registerFactory(
    () => AuthCubit(loginUseCase: sl(), registerUseCase: sl()),
  );
  sl.registerFactory(
    () => PasswordResetCubit(
      forgotPasswordUseCase: sl(),
      verifyCodeUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );
}
