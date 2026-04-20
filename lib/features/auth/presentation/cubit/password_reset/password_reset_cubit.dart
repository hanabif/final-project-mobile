import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/forgot_password_usecase.dart';
import '../../../domain/usecases/forgot_password_otp_usecase.dart';
import '../../../domain/usecases/reset_password_usecase.dart';
import '../../../domain/usecases/verify_code_usecase.dart';
import 'password_reset_state.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ForgotPasswordOtpUseCase forgotPasswordOtpUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  PasswordResetCubit({
    required this.forgotPasswordUseCase,
    required this.forgotPasswordOtpUseCase,
    required this.verifyCodeUseCase,
    required this.resetPasswordUseCase,
  }) : super(PasswordResetInitial());

  Future<void> sendResetEmail(String email) async {
    emit(PasswordResetLoading());
    try {
      await forgotPasswordUseCase(email);
      emit(PasswordResetEmailSent(email));
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }

  Future<void> sendResetOtp(String email) async {
    emit(PasswordResetLoading());
    try {
      await forgotPasswordOtpUseCase(email);
      emit(PasswordResetOtpSent(email));
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }

  Future<void> verifyCode(String email, String code) async {
    emit(PasswordResetLoading());
    try {
      await verifyCodeUseCase(email, code);
      emit(PasswordResetCodeVerified(email, code));
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }

  Future<void> resetPassword(String email, String token, String newPassword) async {
    emit(PasswordResetLoading());
    try {
      await resetPasswordUseCase(email, token, newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }
}