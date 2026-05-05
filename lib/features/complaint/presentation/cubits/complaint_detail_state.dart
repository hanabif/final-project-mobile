import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';

abstract class ComplaintDetailState extends Equatable {
  const ComplaintDetailState();

  @override
  List<Object> get props => [];
}

class ComplaintDetailInitial extends ComplaintDetailState {}

class ComplaintDetailLoading extends ComplaintDetailState {}

class ComplaintDetailLoaded extends ComplaintDetailState {
  final Complaint complaint;

  const ComplaintDetailLoaded({required this.complaint});

  @override
  List<Object> get props => [complaint];
}

class ComplaintDetailError extends ComplaintDetailState {
  final String message;

  const ComplaintDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
