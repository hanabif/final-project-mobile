abstract class PasswordResetState {}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class PasswordResetEmailSent extends PasswordResetState {
  final String email;

  PasswordResetEmailSent(this.email);
}

class PasswordResetOtpSent extends PasswordResetState {
  final String email;

  PasswordResetOtpSent(this.email);
}

class PasswordResetCodeVerified extends PasswordResetState {
  final String email;
  final String token;

  PasswordResetCodeVerified(this.email, this.token);
}

class PasswordResetSuccess extends PasswordResetState {}

class PasswordResetError extends PasswordResetState {
  final String message;

  PasswordResetError(this.message);
}