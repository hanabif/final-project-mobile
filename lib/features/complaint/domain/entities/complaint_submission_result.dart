import 'package:equatable/equatable.dart';

class ComplaintSubmissionResult extends Equatable {
  final String? complaintId;
  final bool isQueued;
  final String message;

  const ComplaintSubmissionResult({
    this.complaintId,
    required this.isQueued,
    required this.message,
  });

  @override
  List<Object?> get props => [complaintId, isQueued, message];
}