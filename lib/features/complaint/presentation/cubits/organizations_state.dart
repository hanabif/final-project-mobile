abstract class OrganizationsState {
  const OrganizationsState();
}

class OrganizationsInitial extends OrganizationsState {
  const OrganizationsInitial();
}

class OrganizationsLoading extends OrganizationsState {
  const OrganizationsLoading();
}

class OrganizationsLoaded extends OrganizationsState {
  final List<Map<String, dynamic>> organizations;

  const OrganizationsLoaded({required this.organizations});
}

class OrganizationsError extends OrganizationsState {
  final String message;

  const OrganizationsError({required this.message});
}
