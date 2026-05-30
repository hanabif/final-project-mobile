import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeOffline extends HomeState {
  final String message;

  const HomeOffline({required this.message});

  @override
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  final int totalComplaints;
  final int resolvedComplaints;
  final int pendingComplaints;
  final List<Map<String, String>> organizations;

  const HomeLoaded({
    required this.totalComplaints,
    required this.resolvedComplaints,
    required this.pendingComplaints,
    required this.organizations,
  });

  @override
  List<Object?> get props => [
        totalComplaints,
        resolvedComplaints,
        pendingComplaints,
        organizations,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
