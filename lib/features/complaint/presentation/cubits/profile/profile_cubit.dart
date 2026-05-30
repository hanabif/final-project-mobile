import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/network/network_info.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../../auth/domain/usecases/get_profile_usecase.dart';
import '../../../../auth/domain/usecases/update_profile_usecase.dart';
import '../../../../auth/domain/usecases/change_password_usecase.dart';
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

class ProfileOffline extends ProfileState {
  final String message;

  ProfileOffline(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final User user;

  ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class PasswordChangeSuccess extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final GetCitizenAnalyticsUseCase getCitizenAnalyticsUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final NetworkInfo networkInfo;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.getCitizenAnalyticsUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.networkInfo,
  }) : super(ProfileInitial());

  Future<void> loadProfileData({bool forceRefresh = false}) async {
    if (!forceRefresh && state is ProfileLoaded) {
      return;
    }

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
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        emit(ProfileOffline('No internet connection. Showing saved profile data when available.'));
        return;
      }

      emit(ProfileError('Unable to load profile right now.'));
    }
  }

  Future<void> updateProfile(String fullName) async {
    emit(ProfileLoading());
    try {
      await updateProfileUseCase(fullName);
      // Fetch fresh profile data after update
      final results = await Future.wait([
        getProfileUseCase.call(),
        getCitizenAnalyticsUseCase.call(),
      ]);

      final user = results[0] as User;
      final stats = results[1] as CitizenAnalyticsModel;

      emit(ProfileUpdateSuccess(user));
      // Re-emit ProfileLoaded to restore UI content with fresh data
      emit(ProfileLoaded(user: user, stats: stats));
    } catch (e) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        emit(ProfileOffline('No internet connection. Showing saved profile data when available.'));
        return;
      }

      emit(ProfileError('Unable to update your profile right now.'));
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(ProfileLoading());
    try {
      await changePasswordUseCase(oldPassword, newPassword);
      // Reload full profile data after password change
      final results = await Future.wait([
        getProfileUseCase.call(),
        getCitizenAnalyticsUseCase.call(),
      ]);

      final user = results[0] as User;
      final stats = results[1] as CitizenAnalyticsModel;

      emit(PasswordChangeSuccess());
      // Re-emit ProfileLoaded to restore UI content
      emit(ProfileLoaded(user: user, stats: stats));
    } catch (e) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        emit(ProfileOffline('No internet connection. Showing saved profile data when available.'));
        return;
      }

      emit(ProfileError('Unable to change password right now.'));
    }
  }

  void clearCache() {
    emit(ProfileInitial());
  }
}
