import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:complaint_resolution_app/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:complaint_resolution_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:complaint_resolution_app/features/settings/domain/entities/user_settings.dart';
import 'package:complaint_resolution_app/features/settings/data/models/user_settings_model.dart';

class MockLocalDataSource extends Mock implements SettingsDataSource {}

void main() {
  late SettingsRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    repository = SettingsRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final tSettings = UserSettings(
    isAnonymousMode: false,
    isNotificationsEnabled: true,
    themeMode: 'Light',
    language: 'en',
  );
  
  final tSettingsModel = UserSettingsModel(
    isAnonymousMode: false,
    isNotificationsEnabled: true,
    themeMode: 'Light',
    language: 'en',
  );

  group('SettingsRepository', () {
    test('should get settings from local data source', () async {
      when(() => mockLocalDataSource.getSettings()).thenAnswer((_) async => tSettingsModel);

      final result = await repository.getSettings();

      expect(result, tSettingsModel);
      verify(() => mockLocalDataSource.getSettings()).called(1);
    });

    test('should update settings in local data source', () async {
      when(() => mockLocalDataSource.updateSettings(any())).thenAnswer((_) async => {});

      await repository.updateSettings(tSettings);

      verify(() => mockLocalDataSource.updateSettings(any())).called(1);
    });
  });

  setUpAll(() {
    registerFallbackValue(tSettingsModel);
  });
}
