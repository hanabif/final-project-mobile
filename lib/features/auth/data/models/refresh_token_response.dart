import 'package:equatable/equatable.dart';

class RefreshTokenResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}
