import 'package:equatable/equatable.dart';

abstract class ComplaintState extends Equatable {
  const ComplaintState();

  @override
  List<Object> get props => [];
}

class ComplaintInitial extends ComplaintState {}

class ComplaintSubmitting extends ComplaintState {}

class ComplaintSuccess extends ComplaintState {
  final String message;
  final bool isQueued;
  final String? complaintId;

  const ComplaintSuccess({
    required this.message,
    required this.isQueued,
    this.complaintId,
  });

  @override
  List<Object> get props => [message, isQueued, complaintId ?? ''];
}

class ComplaintFailure extends ComplaintState {
  final String message;

  const ComplaintFailure({required this.message});

  @override
  List<Object> get props => [message];
}
