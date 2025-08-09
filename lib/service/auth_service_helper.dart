import 'storage/token_storage.dart';

class AuthServiceHelper {
  static final TokenStorage _tokenStorage = TokenStorage();

  /// Check if user is currently authenticated
  static Future<bool> isAuthenticated() async {
    return await _tokenStorage.isTokenValid();
  }

  /// Get current user ID if authenticated
  static Future<String?> getCurrentUserId() async {
    final isValid = await _tokenStorage.isTokenValid();
    if (!isValid) return null;
    
    return await _tokenStorage.getUserId();
  }

  /// Get current username if authenticated
  static Future<String?> getCurrentUsername() async {
    final isValid = await _tokenStorage.isTokenValid();
    if (!isValid) return null;
    
    return await _tokenStorage.getUsername();
  }

  /// Logout user by clearing token
  static Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  /// Get token expiration info for UI display
  static Future<Map<String, dynamic>> getTokenInfo() async {
    final isValid = await _tokenStorage.isTokenValid();
    final expirationDate = await _tokenStorage.getTokenExpirationDate();
    final userId = await _tokenStorage.getUserId();
    final username = await _tokenStorage.getUsername();

    return {
      'isValid': isValid,
      'expirationDate': expirationDate,
      'userId': userId,
      'username': username,
      'timeUntilExpiry': expirationDate != null 
          ? expirationDate.difference(DateTime.now())
          : null,
    };
  }

  /// Check if token will expire soon (within specified duration)
  static Future<bool> willExpireSoon({Duration threshold = const Duration(hours: 1)}) async {
    final expirationDate = await _tokenStorage.getTokenExpirationDate();
    if (expirationDate == null) return true;

    final timeUntilExpiry = expirationDate.difference(DateTime.now());
    return timeUntilExpiry <= threshold;
  }
}