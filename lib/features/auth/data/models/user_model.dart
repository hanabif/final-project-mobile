import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['fullname'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Citizen',
    );
  }
}
