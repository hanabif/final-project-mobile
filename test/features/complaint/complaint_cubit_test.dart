import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/complaint.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/complaint_submission_result.dart';
import 'package:complaint_resolution_app/features/complaint/domain/usecases/submit_complaint_usecase.dart';
import 'package:complaint_resolution_app/features/complaint/domain/usecases/sync_pending_complaints_usecase.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/complaint_cubit.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/complaint_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmitComplaintUseCase extends Mock
    implements SubmitComplaintUseCase {}

class MockSyncPendingComplaintsUseCase extends Mock
  implements SyncPendingComplaintsUseCase {}

class MockConnectivity extends Mock implements Connectivity {}

class MockXFile extends Mock implements XFile {}

class FakeComplaint extends Fake implements Complaint {}

void main() {
  late MockSubmitComplaintUseCase mockSubmitUseCase;
  late MockSyncPendingComplaintsUseCase mockSyncUseCase;
  late MockConnectivity mockConnectivity;
  late ComplaintCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeComplaint());
  });

  setUp(() {
    mockSubmitUseCase = MockSubmitComplaintUseCase();
    mockSyncUseCase = MockSyncPendingComplaintsUseCase();
    mockConnectivity = MockConnectivity();
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream<ConnectivityResult>.empty());
    when(() => mockSyncUseCase()).thenAnswer((_) async {});
    cubit = ComplaintCubit(
      submitComplaintUseCase: mockSubmitUseCase,
      syncPendingComplaintsUseCase: mockSyncUseCase,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tComplaint = Complaint(
    id: '1',
    title: 'Test',
    description: 'Desc',
    latitude: 0.0,
    longitude: 0.0,
    organizationId: '1',
    status: 'Pending',
    createdAt: DateTime.now(),
  );

  final tImageFiles = <XFile>[];

  group('submitComplaint', () {
    blocTest<ComplaintCubit, ComplaintState>(
      'emits [ComplaintSubmitting, ComplaintSuccess] when submission succeeds',
      build: () {
        when(
          () => mockSubmitUseCase(any(), any()),
        ).thenAnswer(
          (_) async => const ComplaintSubmissionResult(
            complaintId: 'success',
            isQueued: false,
            message: 'Complaint submitted successfully!',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.submitComplaint(tComplaint, tImageFiles),
      expect: () => [
        ComplaintSubmitting(),
        const ComplaintSuccess(
          message: 'Complaint submitted successfully!',
          isQueued: false,
          complaintId: 'success',
        ),
      ],
      verify: (_) {
        verify(() => mockSubmitUseCase(tComplaint, tImageFiles)).called(1);
      },
    );

    blocTest<ComplaintCubit, ComplaintState>(
      'emits [ComplaintSubmitting, ComplaintFailure] when submission fails',
      build: () {
        when(
          () => mockSubmitUseCase(any(), any()),
        ).thenThrow(Exception('Failed to submit'));
        return cubit;
      },
      act: (cubit) => cubit.submitComplaint(tComplaint, tImageFiles),
      expect: () => [ComplaintSubmitting(), isA<ComplaintFailure>()],
    );
  });
}
