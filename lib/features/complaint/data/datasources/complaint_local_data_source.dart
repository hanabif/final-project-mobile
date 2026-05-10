import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint_model.dart';
import '../models/organization_model.dart';

abstract class ComplaintLocalDataSource {
  Future<List<OrganizationModel>> getOrganizations();
  Future<void> cacheOrganizations(List<OrganizationModel> organizations);
  Future<List<ComplaintModel>> getComplaints();
  Future<void> cacheComplaints(List<ComplaintModel> complaints);
  Future<void> cacheComplaint(ComplaintModel complaint);
}

const CACHED_ORGANIZATIONS = 'CACHED_ORGANIZATIONS';
const CACHED_COMPLAINTS = 'CACHED_COMPLAINTS';
const CACHED_UNSUBMITTED_COMPLAINTS = 'CACHED_UNSUBMITTED_COMPLAINTS';

class ComplaintLocalDataSourceImpl implements ComplaintLocalDataSource {
  final SharedPreferences sharedPreferences;

  ComplaintLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheOrganizations(List<OrganizationModel> organizations) {
    final jsonString = json.encode(
      organizations.map((e) => e.toJson()).toList(),
    );
    return sharedPreferences.setString(CACHED_ORGANIZATIONS, jsonString);
  }

  @override
  Future<List<OrganizationModel>> getOrganizations() {
    final jsonString = sharedPreferences.getString(CACHED_ORGANIZATIONS);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      final organizations = jsonList
          .map((e) => OrganizationModel.fromJson(e))
          .toList();
      return Future.value(organizations);
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheComplaints(List<ComplaintModel> complaints) {
    final jsonString = json.encode(complaints.map((e) => e.toJson()).toList());
    return sharedPreferences.setString(CACHED_COMPLAINTS, jsonString);
  }

  @override
  Future<List<ComplaintModel>> getComplaints() {
    final jsonString = sharedPreferences.getString(CACHED_COMPLAINTS);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      final complaints = jsonList
          .map((e) => ComplaintModel.fromJson(e))
          .toList();
      return Future.value(complaints);
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheComplaint(ComplaintModel complaint) async {
    final jsonString = sharedPreferences.getString(
      CACHED_UNSUBMITTED_COMPLAINTS,
    );
    List<ComplaintModel> complaints = [];
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      complaints = jsonList.map((e) => ComplaintModel.fromJson(e)).toList();
    }
    complaints.add(complaint);
    final newJsonString = json.encode(
      complaints.map((e) => e.toJson()).toList(),
    );
    await sharedPreferences.setString(
      CACHED_UNSUBMITTED_COMPLAINTS,
      newJsonString,
    );
  }
}
