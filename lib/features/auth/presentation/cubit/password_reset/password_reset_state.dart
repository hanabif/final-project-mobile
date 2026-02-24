abstract class PasswordResetState {}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class PasswordResetEmailSent extends PasswordResetState {
  final String email;

  PasswordResetEmailSent(this.email);
}

class PasswordResetCodeVerified extends PasswordResetState {
  final String email;

  PasswordResetCodeVerified(this.email);
}

class PasswordResetSuccess extends PasswordResetState {}

class PasswordResetError extends PasswordResetState {
  final String message;

  PasswordResetError(this.message);
}