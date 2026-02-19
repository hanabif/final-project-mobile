import 'package:complaint_resolution_app/features/auth/domain/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit({required this.loginUseCase, required this.registerUseCase})
    : super(AuthInitial());

  Future<void> login(String email, String password) async {
    // emit(AuthLoading());
    // try {
    //   final user = await loginUseCase(email, password);
    //   emit(AuthAuthenticated(user));
    // } catch (e) {
    //   emit(AuthError("Login failed"));
    // }
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 2));

    emit(
      AuthAuthenticated(User(id: 1, name: "Test User", email: "test@mail.com")),
    );
  }

  Future<void> register(String name, String email, String password) async {
    // emit(AuthLoading());
    // try {
    //   final user = await registerUseCase(name, email, password);
    //   emit(AuthAuthenticated(user));
    // } catch (e) {
    //   emit(AuthError("Registration failed"));
    // }
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 2));
    emit(
      AuthAuthenticated(User(id: 1, name: "Test User", email: "test@mail.com")),
    );
  }
}
