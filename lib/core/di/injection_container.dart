import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../network/api_client.dart';
import '../utils/secure_storage.dart';
import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/data/repositories/session_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/repositories/session_repository.dart';
import '../../../features/auth/domain/usecases/login_usecase.dart';
import '../../../features/auth/domain/usecases/register_usecase.dart';
import '../../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../../features/auth/domain/usecases/verify_code_usecase.dart';
import '../../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../../features/auth/domain/usecases/save_token_usecase.dart';
import '../../../features/auth/domain/usecases/get_token_usecase.dart';
import '../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../features/auth/domain/usecases/is_session_valid_usecase.dart';
import '../../../features/auth/presentation/cubit/auth/auth_cubit.dart';
import '../../../features/auth/domain/usecases/get_profile_usecase.dart';
import '../../../features/auth/domain/usecases/forgot_password_otp_usecase.dart';
import '../../../features/auth/presentation/cubit/password_reset/password_reset_cubit.dart';
import '../network/deep_link_service.dart';

import '../../../features/complaint/data/datasources/complaint_remote_datasource.dart';
import '../../../features/complaint/data/repositories/complaint_repository_impl.dart';
import '../../../features/complaint/domain/repositories/complaint_repository.dart';
import '../../../features/complaint/domain/usecases/submit_complaint_usecase.dart';
import '../../../features/complaint/domain/usecases/get_complaint_status_usecase.dart';
import '../../../features/complaint/domain/usecases/get_user_complaints_usecase.dart';
import '../../../features/complaint/domain/usecases/get_complaint_detail_usecase.dart';
import '../../../features/complaint/presentation/cubits/complaint_cubit.dart';
import '../../../features/complaint/presentation/cubits/complaint_list_cubit.dart';
import '../../../features/complaint/presentation/cubits/complaint_detail_cubit.dart';
import '../../../features/complaint/presentation/cubits/home/home_cubit.dart';
import '../../../features/complaint/domain/usecases/get_citizen_analytics_usecase.dart';
import '../../../features/complaint/domain/usecases/get_organizations_usecase.dart';
import '../../../features/complaint/presentation/cubits/profile/profile_cubit.dart';
import '../../../features/settings/presentation/cubits/settings_cubit.dart';
import '../../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../../features/notification/domain/repositories/notification_repository.dart';
import '../../../features/notification/presentation/services/firebase_notification_service.dart';
import '../../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../../../features/settings/domain/usecases/get_settings_usecase.dart';
import '../../../features/settings/domain/usecases/update_settings_usecase.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => ImagePicker());

  // Core
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
  sl.registerLazySingleton<DeepLinkService>(() => DeepLinkService());

  // Auth - Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Complaint - Data sources
  sl.registerLazySingleton<ComplaintRemoteDataSource>(
    () => ComplaintRemoteDataSourceImpl(apiClient: sl()),
  );

  // Notification - Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );


  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Complaint - Repository
  sl.registerLazySingleton<ComplaintRepository>(
    () => ComplaintRepositoryImpl(remoteDataSource: sl()),
  );

  // Notification - Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );


  // Auth - Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordOtpUseCase(sl()));
  sl.registerLazySingleton(() => SaveTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => IsSessionValidUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));

  // Notifications
  sl.registerLazySingleton<FirebaseNotificationService>(
    () => FirebaseNotificationService(sl()),
  );


  // Complaint - Use cases
  sl.registerLazySingleton(() => SubmitComplaintUseCase(sl()));
  sl.registerLazySingleton(() => GetComplaintStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetUserComplaintsUseCase(sl()));
  sl.registerLazySingleton(() => GetComplaintDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetCitizenAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizationsUseCase(sl()));

  // Auth - Presentation
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerFactory(
    () => PasswordResetCubit(
      forgotPasswordUseCase: sl(),
      forgotPasswordOtpUseCase: sl(),
      verifyCodeUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );

  // Complaint - Presentation
  sl.registerFactory(() => HomeCubit(
        getCitizenAnalyticsUseCase: sl(),
        getOrganizationsUseCase: sl(),
      ));
  sl.registerFactory(() => ComplaintCubit(submitComplaintUseCase: sl()));
  sl.registerFactory(() => ComplaintListCubit(getUserComplaintsUseCase: sl()));
  sl.registerFactory(
    () => ComplaintDetailCubit(getComplaintDetailUseCase: sl()),
  );
  sl.registerFactory(
    () => ProfileCubit(
      getProfileUseCase: sl(),
      getCitizenAnalyticsUseCase: sl(),
    ),
  );

  // Settings
  sl.registerFactory(() => SettingsCubit(
        getSettingsUseCase: sl(),
        updateSettingsUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSettingsUseCase(sl()));
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsRemoteDataSourceImpl());
}
