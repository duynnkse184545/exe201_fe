import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:io';

part 'user.freezed.dart';

part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String userId,
    required String fullName,
    required String userName,
    required String email,
    DateTime? doB,
    String? passwordHash,
    DateTime? lastLogin,
    String? img,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int roleId,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class UserRequest with _$UserRequest {
  const factory UserRequest({
    required String? fullName,
    required String userName,
    required String email,
    @JsonKey(toJson: _dateToString, fromJson: _dateFromString) DateTime? doB,
    @JsonKey(fromJson: _fileFromJson, toJson: _fileToJson) File? img,
    required String? passwordHash,
    required int roleId,
  }) = _UserRequest;

  factory UserRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRequestFromJson(json);
}

File? _fileFromJson(String? path) => path == null ? null : File(path);

String? _fileToJson(File? file) => file?.path;

// Helper functions for date conversion
String? _dateToString(DateTime? date) {
  return date?.toIso8601String().split('T')[0]; // Returns YYYY-MM-DD
}

DateTime? _dateFromString(String? dateString) {
  return dateString != null ? DateTime.parse(dateString) : null;
}
