import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: (json['fullname'] ?? json['name'])?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: json['role']?.toString() ?? 'Citizen',
      );
    } catch (e) {
      print('Error parsing UserModel: $e, json: $json');
      rethrow;
    }
  }
}
