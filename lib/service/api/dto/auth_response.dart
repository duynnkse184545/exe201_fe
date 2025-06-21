class AuthResponse {
  final String token;
  final String username;

  AuthResponse({
    required this.token,
    required this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final user = data['loginResModel'];

    return AuthResponse(
      token: data['token'],
      username: user['userName'],
    );
  }
}
