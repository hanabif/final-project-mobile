import 'package:bloc_test/bloc_test.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/complaint.dart';
import 'package:complaint_resolution_app/features/complaint/domain/usecases/get_user_complaints_usecase.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/complaint_list_cubit.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/complaint_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUserComplaintsUseCase extends Mock implements GetUserComplaintsUseCase {}

void main() {
  late MockGetUserComplaintsUseCase mockGetComplaintsUseCase;
  late ComplaintListCubit cubit;

  setUp(() {
    mockGetComplaintsUseCase = MockGetUserComplaintsUseCase();
    cubit = ComplaintListCubit(getUserComplaintsUseCase: mockGetComplaintsUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  final tComplaints = [
    Complaint(
      id: '1',
      title: 'Test',
      description: 'Desc',
      latitude: 0.0,
      longitude: 0.0,
      organizationId: '1',
      status: 'Pending',
      createdAt: DateTime.now(),
    ),
  ];

  group('fetchComplaints', () {
    blocTest<ComplaintListCubit, ComplaintListState>(
      'emits [ComplaintListLoading, ComplaintListLoaded] when fetching succeeds',
      build: () {
        when(() => mockGetComplaintsUseCase()).thenAnswer((_) async => tComplaints);
        return cubit;
      },
      act: (cubit) => cubit.fetchComplaints(),
      expect: () => [
        ComplaintListLoading(),
        ComplaintListLoaded(complaints: tComplaints),
      ],
    );

    blocTest<ComplaintListCubit, ComplaintListState>(
      'emits [ComplaintListLoading, ComplaintListError] when fetching fails',
      build: () {
        when(() => mockGetComplaintsUseCase()).thenThrow(Exception('Error'));
        return cubit;
      },
      act: (cubit) => cubit.fetchComplaints(),
      expect: () => [
        ComplaintListLoading(),
        isA<ComplaintListError>(),
      ],
    );
  });
}
