import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:complaint_resolution_app/core/network/network_info.dart';
import 'package:complaint_resolution_app/features/complaint/data/datasources/complaint_local_data_source.dart';
import 'package:complaint_resolution_app/features/complaint/data/datasources/complaint_remote_datasource.dart';
import 'package:complaint_resolution_app/features/complaint/data/models/complaint_model.dart';
import 'package:complaint_resolution_app/features/complaint/data/repositories/complaint_repository_impl.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/complaint.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/complaint_submission_result.dart';
import 'package:complaint_resolution_app/features/complaint/data/models/citizen_analytics_model.dart';

class MockRemoteDataSource extends Mock implements ComplaintRemoteDataSource {}

class MockLocalDataSource extends Mock implements ComplaintLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ComplaintRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ComplaintRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tComplaintId = '1';
  final tComplaintModel = ComplaintModel(
    id: tComplaintId,
    title: 'Test',
    description: 'Test',
    category: 'Test',
    organizationId: '1',
    status: 'pending',
    latitude: 0.0,
    longitude: 0.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final Complaint tComplaint = tComplaintModel;

  group('submitComplaint', () {
    test('should submit to remote when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.submitComplaint(any()),
      ).thenAnswer((_) async => 'Success');
      when(() => mockRemoteDataSource.moderateComplaint(any()))
          .thenAnswer((_) async {});

      final result = await repository.submitComplaint(tComplaint);

      expect(
        result,
        const ComplaintSubmissionResult(
          complaintId: 'Success',
          isQueued: false,
          message: 'Complaint submitted successfully!',
        ),
      );
      verify(() => mockRemoteDataSource.submitComplaint(any())).called(1);
      verify(() => mockRemoteDataSource.moderateComplaint('Success')).called(1);
    });

    test('should cache locally when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalDataSource.cacheComplaint(any()),
      ).thenAnswer((_) async => {});

      final result = await repository.submitComplaint(tComplaint);

      expect(result.isQueued, isTrue);
      verify(() => mockLocalDataSource.cacheComplaint(any())).called(1);
      verifyNever(() => mockRemoteDataSource.submitComplaint(any()));
    });
  });

  group('syncPendingComplaints', () {
    test('should replay queued complaints when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getQueuedComplaints())
          .thenAnswer((_) async => [tComplaintModel]);
      when(() => mockRemoteDataSource.submitComplaint(any()))
          .thenAnswer((_) async => 'Success');
      when(() => mockRemoteDataSource.moderateComplaint(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.removeQueuedComplaint(any()))
          .thenAnswer((_) async {});

      await repository.syncPendingComplaints();

      verify(() => mockRemoteDataSource.submitComplaint(any())).called(1);
      verify(() => mockRemoteDataSource.moderateComplaint('Success')).called(1);
      verify(() => mockLocalDataSource.removeQueuedComplaint(tComplaintId)).called(1);
    });
  });

  group('getComplaintStatus', () {
    test('should return status from remote', () async {
      when(
        () => mockRemoteDataSource.getComplaintStatus(any()),
      ).thenAnswer((_) async => tComplaintModel);

      final result = await repository.getComplaintStatus(tComplaintId);

      expect(result, 'pending');
      verify(
        () => mockRemoteDataSource.getComplaintStatus(tComplaintId),
      ).called(1);
    });
  });

  group('getUserComplaints', () {
    test('should return remote data when forced and online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getUserComplaints(),
      ).thenAnswer((_) async => [tComplaintModel]);
      when(
        () => mockLocalDataSource.cacheComplaints(any()),
      ).thenAnswer((_) async => {});

      final result = await repository.getUserComplaints(forceRefresh: true);

      expect(result, [tComplaintModel]);
      verify(() => mockRemoteDataSource.getUserComplaints()).called(1);
      verify(() => mockLocalDataSource.cacheComplaints(any())).called(1);
    });

    test('should return local data when available and not forced', () async {
      final List<ComplaintModel> tComplaints = [
        ComplaintModel(
          id: '1',
          title: 'Resolved',
          description: 'Desc',
          category: 'Cat',
          organizationId: 'Org',
          status: 'resolved',
          latitude: 0.0,
          longitude: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(
        () => mockLocalDataSource.getComplaints(),
      ).thenAnswer((_) async => tComplaints);

      final result = await repository.getUserComplaints(forceRefresh: false);

      expect(result, tComplaints);
      verify(() => mockLocalDataSource.getComplaints()).called(1);
      verifyNever(() => mockRemoteDataSource.getUserComplaints());
    });
  });

  group('getCitizenAnalytics', () {
    test('should return analytics from remote', () async {
      final tAnalytics = CitizenAnalyticsModel(
        total: 10,
        pending: 5,
        resolved: 5,
        resolvedPercentage: 50.0,
      );
      when(
        () => mockRemoteDataSource.getCitizenAnalytics(),
      ).thenAnswer((_) async => tAnalytics);

      final result = await repository.getCitizenAnalytics();

      expect(result, tAnalytics);
      verify(() => mockRemoteDataSource.getCitizenAnalytics()).called(1);
    });
  });

  setUpAll(() {
    registerFallbackValue(tComplaintModel);
    registerFallbackValue([tComplaintModel]);
  });
}
