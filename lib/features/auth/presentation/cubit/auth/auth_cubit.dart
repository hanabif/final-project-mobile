import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../../notification/presentation/services/firebase_notification_service.dart';
import '../../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final FirebaseNotificationService notificationService;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.notificationService,
  }) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(email, password);
      
      // Register device token for notifications
      await notificationService.getDeviceToken();
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(name, email, password, 'Citizen');
      
      // Register device token for notifications
      await notificationService.getDeviceToken();
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(AuthInitial()); // Or AuthUnauthenticated if you have that state
    } catch (e) {
      // Even if logout fails on server, we should probably unauthenticate locally
      emit(AuthInitial());
    }
  }
}
