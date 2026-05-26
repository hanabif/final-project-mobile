import 'package:bloc_test/bloc_test.dart';
import 'package:complaint_resolution_app/features/settings/domain/entities/user_settings.dart';
import 'package:complaint_resolution_app/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:complaint_resolution_app/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:complaint_resolution_app/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:complaint_resolution_app/features/settings/presentation/cubits/settings_state.dart';
import 'package:complaint_resolution_app/features/notification/presentation/services/firebase_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}

class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

class MockNotificationService extends Mock
  implements FirebaseNotificationService {}

class FakeUserSettings extends Fake implements UserSettings {}

void main() {
  late MockGetSettingsUseCase mockGetSettings;
  late MockUpdateSettingsUseCase mockUpdateSettings;
  late MockNotificationService mockNotificationService;
  late SettingsCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeUserSettings());
  });

  setUp(() {
    mockGetSettings = MockGetSettingsUseCase();
    mockUpdateSettings = MockUpdateSettingsUseCase();
    mockNotificationService = MockNotificationService();
    cubit = SettingsCubit(
      getSettingsUseCase: mockGetSettings,
      updateSettingsUseCase: mockUpdateSettings,
      notificationService: mockNotificationService,
    );
    when(() => mockNotificationService.getDeviceToken())
        .thenAnswer((_) async => 'token');
    when(() => mockNotificationService.unregisterDevice())
        .thenAnswer((_) async {});
  });

  tearDown(() {
    cubit.close();
  });

  const tSettings = UserSettings(
    isAnonymousMode: false,
    isNotificationsEnabled: true,
    themeMode: 'Light',
    language: 'English',
  );

  const tNotificationsDisabled = UserSettings(
    isAnonymousMode: false,
    isNotificationsEnabled: false,
    themeMode: 'Light',
    language: 'English',
  );

  group('loadSettings', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits [SettingsLoading, SettingsLoaded] when loading succeeds',
      build: () {
        when(() => mockGetSettings()).thenAnswer((_) async => tSettings);
        return cubit;
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        SettingsLoading(),
        const SettingsLoaded(settings: tSettings),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [SettingsLoading, SettingsError] when loading fails',
      build: () {
        when(() => mockGetSettings()).thenThrow(Exception('Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadSettings(),
      expect: () => [SettingsLoading(), isA<SettingsError>()],
    );
  });

  group('toggleAnonymousMode', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits updated SettingsLoaded when toggle succeeds',
      seed: () => const SettingsLoaded(settings: tSettings),
      build: () {
        when(() => mockUpdateSettings(any())).thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) => cubit.toggleAnonymousMode(true),
      expect: () => [
        const SettingsLoaded(
          settings: UserSettings(
            isAnonymousMode: true,
            isNotificationsEnabled: true,
            themeMode: 'Light',
            language: 'English',
          ),
        ),
      ],
    );
  });

  group('toggleNotifications', () {
    blocTest<SettingsCubit, SettingsState>(
      're-registers device when notifications are enabled',
      build: () {
        when(() => mockGetSettings()).thenAnswer((_) async => tNotificationsDisabled);
        when(() => mockUpdateSettings(any())).thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadSettings();
        await cubit.toggleNotifications(true);
      },
      expect: () => [
        SettingsLoading(),
        const SettingsLoaded(settings: tNotificationsDisabled),
        const SettingsLoaded(
          settings: UserSettings(
            isAnonymousMode: false,
            isNotificationsEnabled: true,
            themeMode: 'Light',
            language: 'English',
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockNotificationService.getDeviceToken()).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'unregisters device when notifications are disabled',
      build: () {
        when(() => mockGetSettings()).thenAnswer((_) async => tSettings);
        when(() => mockUpdateSettings(any())).thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadSettings();
        await cubit.toggleNotifications(false);
      },
      expect: () => [
        SettingsLoading(),
        const SettingsLoaded(settings: tSettings),
        const SettingsLoaded(
          settings: UserSettings(
            isAnonymousMode: false,
            isNotificationsEnabled: false,
            themeMode: 'Light',
            language: 'English',
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockNotificationService.unregisterDevice()).called(1);
      },
    );
  });
}
