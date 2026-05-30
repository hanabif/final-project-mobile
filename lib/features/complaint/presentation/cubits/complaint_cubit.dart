import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/submit_complaint_usecase.dart';
import '../../domain/usecases/sync_pending_complaints_usecase.dart';
import 'complaint_state.dart';

class ComplaintCubit extends Cubit<ComplaintState> {
  final SubmitComplaintUseCase submitComplaintUseCase;
  final SyncPendingComplaintsUseCase syncPendingComplaintsUseCase;
  final Connectivity connectivity;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncingPendingComplaints = false;

  ComplaintCubit({
    required this.submitComplaintUseCase,
    required this.syncPendingComplaintsUseCase,
    required this.connectivity,
  }) : super(ComplaintInitial()) {
    _listenForConnectivityChanges();
    Future.microtask(_syncPendingComplaints);
  }

  Future<void> submitComplaint(Complaint complaint, List<XFile> imageFiles) async {
    emit(ComplaintSubmitting());


    try {
      final result = await submitComplaintUseCase(complaint, imageFiles);
      emit(ComplaintSuccess(
        message: result.message,
        isQueued: result.isQueued,
        complaintId: result.complaintId,
      ));
    } catch (e) {
      emit(ComplaintFailure(message: _mapErrorToMessage(e)));
    }
  }

  void _listenForConnectivityChanges() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncPendingComplaints();
      }
    });
  }

  Future<void> _syncPendingComplaints() async {
    if (_isSyncingPendingComplaints) {
      return;
    }

    _isSyncingPendingComplaints = true;
    try {
      await syncPendingComplaintsUseCase();
    } catch (_) {
      // Keep offline replay silent; the queue will retry on the next reconnect.
    } finally {
      _isSyncingPendingComplaints = false;
    }
  }

  String _mapErrorToMessage(Object error) {
    final raw = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    final normalized = raw.toLowerCase();

    if (normalized.contains('network error') ||
        normalized.contains('socketexception') ||
        normalized.contains('connection timed out') ||
        normalized.contains('connection error')) {
      return 'Unable to submit your complaint right now. Please try again when your connection is stable.';
    }

    return raw.isNotEmpty ? raw : 'Something went wrong. Please try again.';
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
