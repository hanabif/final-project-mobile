import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:complaint_resolution_app/app.dart' as app;
import 'package:complaint_resolution_app/core/di/injection_container.dart'
    as di;
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Features - Auth
import 'package:complaint_resolution_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/session_repository.dart';
import 'package:complaint_resolution_app/features/auth/domain/entities/user.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/is_session_valid_usecase.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/forgot_password_otp_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/password_reset/password_reset_cubit.dart';

// Features - Settings
import 'package:complaint_resolution_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:complaint_resolution_app/features/settings/domain/entities/user_settings.dart';
import 'package:complaint_resolution_app/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:complaint_resolution_app/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:complaint_resolution_app/features/settings/presentation/cubits/settings_cubit.dart';

// Features - Complaint
import 'package:complaint_resolution_app/features/complaint/domain/repositories/complaint_repository.dart';
import 'package:complaint_resolution_app/features/complaint/data/models/citizen_analytics_model.dart';
import 'package:complaint_resolution_app/features/complaint/domain/usecases/get_citizen_analytics_usecase.dart';
import 'package:complaint_resolution_app/features/complaint/domain/usecases/get_organizations_usecase.dart';
import 'package:complaint_resolution_app/features/complaint/domain/usecases/submit_complaint_usecase.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/home/home_cubit.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/complaint_cubit.dart';

// Features - Notification
import 'package:complaint_resolution_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:complaint_resolution_app/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:complaint_resolution_app/features/notification/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:complaint_resolution_app/features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:complaint_resolution_app/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:complaint_resolution_app/features/notification/presentation/services/firebase_notification_service.dart';

// Core
import 'package:complaint_resolution_app/core/network/deep_link_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockComplaintRepository extends Mock implements ComplaintRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockFirebaseNotificationService extends Mock
    implements FirebaseNotificationService {}

class MockDeepLinkService extends Mock implements DeepLinkService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockSessionRepository mockSessionRepository;
  late MockSettingsRepository mockSettingsRepository;
  late MockComplaintRepository mockComplaintRepository;
  late MockNotificationRepository mockNotificationRepository;
  late MockFirebaseNotificationService mockNotificationService;
  late MockDeepLinkService mockDeepLinkService;

  setUp(() async {
    await di.sl.reset();

    mockAuthRepository = MockAuthRepository();
    mockSessionRepository = MockSessionRepository();
    mockSettingsRepository = MockSettingsRepository();
    mockComplaintRepository = MockComplaintRepository();
    mockNotificationRepository = MockNotificationRepository();
    mockNotificationService = MockFirebaseNotificationService();
    mockDeepLinkService = MockDeepLinkService();

    // Register essential external dependencies
    di.sl.registerLazySingleton<SharedPreferences>(
      () => MockSharedPreferences(),
    );
    di.sl.registerLazySingleton<DeepLinkService>(() => mockDeepLinkService);
    di.sl.registerLazySingleton<FirebaseNotificationService>(
      () => mockNotificationService,
    );

    // Register Repositories
    di.sl.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
    di.sl.registerLazySingleton<SessionRepository>(() => mockSessionRepository);
    di.sl.registerLazySingleton<SettingsRepository>(
      () => mockSettingsRepository,
    );
    di.sl.registerLazySingleton<ComplaintRepository>(
      () => mockComplaintRepository,
    );
    di.sl.registerLazySingleton<NotificationRepository>(
      () => mockNotificationRepository,
    );

    // Register UseCases
    di.sl.registerLazySingleton(() => LoginUseCase(di.sl()));
    di.sl.registerLazySingleton(() => RegisterUseCase(di.sl()));
    di.sl.registerLazySingleton(() => LogoutUseCase(di.sl()));
    di.sl.registerLazySingleton(() => IsSessionValidUseCase(di.sl()));
    di.sl.registerLazySingleton(() => GetSettingsUseCase(di.sl()));
    di.sl.registerLazySingleton(() => UpdateSettingsUseCase(di.sl()));
    di.sl.registerLazySingleton(() => GetCitizenAnalyticsUseCase(di.sl()));
    di.sl.registerLazySingleton(() => GetOrganizationsUseCase(di.sl()));
    di.sl.registerLazySingleton(() => SubmitComplaintUseCase(di.sl()));
    di.sl.registerLazySingleton(() => GetNotificationsUseCase(di.sl()));
    di.sl.registerLazySingleton(
      () => MarkAllNotificationsAsReadUseCase(di.sl()),
    );
    di.sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(di.sl()));
    di.sl.registerLazySingleton(() => ForgotPasswordUseCase(di.sl()));
    di.sl.registerLazySingleton(() => ForgotPasswordOtpUseCase(di.sl()));
    di.sl.registerLazySingleton(() => VerifyCodeUseCase(di.sl()));
    di.sl.registerLazySingleton(() => ResetPasswordUseCase(di.sl()));

    // Register Cubits
    di.sl.registerFactory(
      () => AuthCubit(
        loginUseCase: di.sl(),
        registerUseCase: di.sl(),
        logoutUseCase: di.sl(),
        notificationService: di.sl(),
      ),
    );

    di.sl.registerFactory(
      () => SettingsCubit(
        getSettingsUseCase: di.sl(),
        updateSettingsUseCase: di.sl(),
      ),
    );

    di.sl.registerFactory(
      () => HomeCubit(
        getCitizenAnalyticsUseCase: di.sl(),
        getOrganizationsUseCase: di.sl(),
      ),
    );

    di.sl.registerFactory(
      () => ComplaintCubit(submitComplaintUseCase: di.sl()),
    );

    di.sl.registerFactory(() => NotificationCubit(di.sl(), di.sl(), di.sl()));

    di.sl.registerFactory(
      () => PasswordResetCubit(
        forgotPasswordUseCase: di.sl(),
        forgotPasswordOtpUseCase: di.sl(),
        verifyCodeUseCase: di.sl(),
        resetPasswordUseCase: di.sl(),
      ),
    );

    // Common stubs
    when(() => mockDeepLinkService.initialize()).thenReturn(null);
    when(() => mockNotificationService.initialize()).thenAnswer((_) async {});
    when(
      () => mockNotificationService.getDeviceToken(),
    ).thenAnswer((_) async => 'mock-token');
  });

  group('App Integration Test', () {
    testWidgets('verify login flow with mocked repository', (tester) async {
      // 1. Stub dependencies
      when(
        () => mockSessionRepository.hasValidSession(),
      ).thenAnswer((_) async => false);
      when(() => mockSettingsRepository.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          isAnonymousMode: false,
          isNotificationsEnabled: true,
          themeMode: 'Light',
          language: 'en',
        ),
      );

      when(() => mockAuthRepository.login(any(), any())).thenAnswer(
        (_) async => const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: 'citizen',
        ),
      );
      when(
        () => mockSessionRepository.saveToken(any()),
      ).thenAnswer((_) async => Future.value());

      // Stub Home Data
      when(
        () => mockComplaintRepository.getCitizenAnalytics(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => CitizenAnalyticsModel(
          total: 5,
          resolved: 2,
          pending: 3,
          resolvedPercentage: 0.4,
        ),
      );
      when(
        () => mockComplaintRepository.getOrganizations(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => mockNotificationRepository.getNotifications(),
      ).thenAnswer((_) async => []);

      // 2. Start the app
      await tester.pumpWidget(const app.ComplaintResolutionApp());
      await tester.pumpAndSettle(); // Initial pump

      // Wait for splash (2 seconds in code)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 3. Verify we are on Login page
      expect(find.text('Login'), findsWidgets);

      // 4. Enter credentials
      final emailFields = find.byType(TextField);
      await tester.enterText(emailFields.at(0), 'test@example.com');
      await tester.enterText(emailFields.at(1), 'password123');
      await tester.pump();

      // 5. Tap Login button (PrimaryButton has text "Login")
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();

      // 6. Verify we navigated to Home
      expect(find.text('Login successful'), findsOneWidget);
    });
  });
}
