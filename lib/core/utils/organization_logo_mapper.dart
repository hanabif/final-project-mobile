/// Maps organization names from the API to their corresponding logo asset paths.
class OrganizationLogoMapper {
  static const Map<String, String> _logoMap = {
    'Addis Ababa Water & Sewerage Authority': 'assets/images/AAWSA.jpg',
    'Ethiopian Electric Utility': 'assets/images/EEU.png',
    'Water Authority': 'assets/images/water.png',
    'Electric Utility': 'assets/images/electric.png',
    'Road Authority': 'assets/images/road.png',
  };

  /// Get the logo path for an organization by name.
  /// Returns a default icon path if the organization is not found.
  static String getLogoPath(String organizationName) {
    return _logoMap[organizationName] ?? 'assets/icons/default_org.png';
  }

  /// Check if an organization has a mapped logo.
  static bool hasLogo(String organizationName) {
    return _logoMap.containsKey(organizationName);
  }
}
