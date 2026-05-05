import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';

abstract class ComplaintListState extends Equatable {
  const ComplaintListState();

  @override
  List<Object> get props => [];
}

class ComplaintListInitial extends ComplaintListState {}

class ComplaintListLoading extends ComplaintListState {}

class ComplaintListLoaded extends ComplaintListState {
  final List<Complaint> complaints;

  const ComplaintListLoaded({required this.complaints});

  @override
  List<Object> get props => [complaints];
}

class ComplaintListError extends ComplaintListState {
  final String message;

  const ComplaintListError({required this.message});

  @override
  List<Object> get props => [message];
}
