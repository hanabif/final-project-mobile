import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../../auth/domain/usecases/get_profile_usecase.dart';
import '../../../data/models/citizen_analytics_model.dart';
import '../../../domain/usecases/get_citizen_analytics_usecase.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final CitizenAnalyticsModel stats;

  ProfileLoaded({required this.user, required this.stats});

  @override
  List<Object?> get props => [user, stats];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final GetCitizenAnalyticsUseCase getCitizenAnalyticsUseCase;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.getCitizenAnalyticsUseCase,
  }) : super(ProfileInitial());

  Future<void> loadProfileData() async {
    emit(ProfileLoading());
    try {
      // Run both calls in parallel
      final results = await Future.wait([
        getProfileUseCase.call(),
        getCitizenAnalyticsUseCase.call(),
      ]);

      final user = results[0] as User;
      final stats = results[1] as CitizenAnalyticsModel;

      emit(ProfileLoaded(user: user, stats: stats));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
