class User {
  final String? userId;
  final String? fullName;
  final String? userName;
  final String? email;
  final DateTime? doB;
  final String? passwordHash;
  final DateTime? lastLogin;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.userId,
    required this.fullName,
    required this.userName,
    required this.email,
    this.doB,
    required this.passwordHash,
    this.lastLogin,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      fullName: json['fullName'],
      userName: json['userName'],
      email: json['email'],
      doB: json['doB'] != null ? DateTime.parse(json['doB']) : null,
      passwordHash: json['passwordHash'],
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isVerified: json['isVerified'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Generate a new GUID for user creation, or omit if backend handles it
      'userId': userId,
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'doB': doB != null ? _formatDateOnly(doB!) : null,
      'passwordHash': passwordHash,
      'lastLogin': lastLogin?.toIso8601String(),
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static String _formatDateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
