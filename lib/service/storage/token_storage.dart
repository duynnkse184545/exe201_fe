import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _keyToken = 'auth_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Decode the stored JWT token and return its payload
  Future<Map<String, dynamic>?> getDecodedToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      return JwtDecoder.decode(token);
    } catch (e) {
      // Token is invalid or corrupted
      return null;
    }
  }

  /// Check if the stored token is expired
  Future<bool> isTokenExpired() async {
    try {
      final token = await getToken();
      if (token == null) return true;
      
      return JwtDecoder.isExpired(token);
    } catch (e) {
      // If we can't decode the token, consider it expired
      return true;
    }
  }

  /// Get the expiration date of the stored token
  Future<DateTime?> getTokenExpirationDate() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }

  /// Get user ID from the token payload
  Future<String?> getUserId() async {
    final decoded = await getDecodedToken();
    if (decoded == null) return null;
    
    // Common JWT claims for user ID
    return decoded['sub'] ?? 
           decoded['userId'] ?? 
           decoded['user_id'] ?? 
           decoded['id'];
  }

  /// Get username from the token payload
  Future<String?> getUsername() async {
    final decoded = await getDecodedToken();
    if (decoded == null) return null;
    
    // Common JWT claims for username
    return decoded['username'] ?? 
           decoded['name'] ?? 
           decoded['preferred_username'] ?? 
           decoded['email'];
  }

  /// Get user roles from the token payload
  Future<List<String>?> getUserRoles() async {
    final decoded = await getDecodedToken();
    if (decoded == null) return null;
    
    // Handle different role claim formats
    final roles = decoded['roles'] ?? 
                  decoded['role'] ?? 
                  decoded['authorities'] ?? 
                  decoded['groups'];
    
    if (roles == null) return null;
    
    if (roles is List) {
      return roles.cast<String>();
    } else if (roles is String) {
      return [roles];
    }
    
    return null;
  }

  /// Get a specific claim from the token payload
  Future<dynamic> getClaim(String claimName) async {
    final decoded = await getDecodedToken();
    return decoded?[claimName];
  }

  /// Check if the token is valid (exists and not expired)
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    return !await isTokenExpired();
  }
}
