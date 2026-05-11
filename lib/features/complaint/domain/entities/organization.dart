import 'package:equatable/equatable.dart';

class Organization extends Equatable {
  final String id;
  final String name;
  final String logo;

  const Organization({
    required this.id,
    required this.name,
    required this.logo,
  });

  @override
  List<Object?> get props => [id, name, logo];
}
