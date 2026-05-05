abstract class SessionRepository {
  /// Save the authentication token securely.
  Future<void> saveToken(String token);

  /// Retrieve the stored authentication token, or null if not set.
  Future<String?> getToken();

  /// Clear any stored session data (e.g. during logout).
  Future<void> clearSession();

  /// Whether the current session is still valid (token exists and is not expired).
  Future<bool> hasValidSession();
}
