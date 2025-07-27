import 'package:freezed_annotation/freezed_annotation.dart';
part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User{
  const factory User({
    required String userId,
    required String fullName,
    required String userName,
    required String email,
    DateTime? doB,
    required String passwordHash,
    DateTime? lastLogin,
    String? img,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int roleId
  }) = _User;

  factory User.fromJson(Map<String,dynamic> json) =>
      _$UserFromJson(json);
}

@freezed
abstract class UserRequest with _$UserRequest{
  const factory UserRequest({
    required String? fullName,
    required String userName,
    required String email,
    DateTime? doB,
    required String passwordHash,
    required int roleId
  }) = _UserRequest;

  factory UserRequest.fromJson(Map<String,dynamic> json) =>
      _$UserRequestFromJson(json);
}
