import 'package:bloc_test/bloc_test.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/complaint.dart';
import 'package:complaint_resolution_app/features/complaint/domain/usecases/submit_complaint_usecase.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/complaint_cubit.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/complaint_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmitComplaintUseCase extends Mock
    implements SubmitComplaintUseCase {}

class MockXFile extends Mock implements XFile {}

class FakeComplaint extends Fake implements Complaint {}

void main() {
  late MockSubmitComplaintUseCase mockSubmitUseCase;
  late ComplaintCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeComplaint());
  });

  setUp(() {
    mockSubmitUseCase = MockSubmitComplaintUseCase();
    cubit = ComplaintCubit(submitComplaintUseCase: mockSubmitUseCase);
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
        ).thenAnswer((_) async => 'success');
        return cubit;
      },
      act: (cubit) => cubit.submitComplaint(tComplaint, tImageFiles),
      expect: () => [ComplaintSubmitting(), ComplaintSuccess()],
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
