import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/forgot_password_usecase.dart';
import '../../../domain/usecases/reset_password_usecase.dart';
import '../../../domain/usecases/verify_code_usecase.dart';
import 'password_reset_state.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  PasswordResetCubit({
    required this.forgotPasswordUseCase,
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

  Future<void> verifyCode(String email, String code) async {
    emit(PasswordResetLoading());
    try {
      await verifyCodeUseCase(email, code);
      emit(PasswordResetCodeVerified(email));
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    emit(PasswordResetLoading());
    try {
      await resetPasswordUseCase(email, newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }
}