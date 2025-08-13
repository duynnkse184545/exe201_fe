import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../model/user/user.dart';
import '../service/api/user_service.dart';
import 'service_providers.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User?> build() async {
    final userService = ref.watch(userServiceProvider);
    try {
      final user = await userService.getUserData();
      return user;
    } catch (e) {
      print('Failed to load user data: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    DateTime? doB,
    File? img,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    state = const AsyncValue.loading();

    try {
      final userService = ref.read(userServiceProvider); // ✅ use ref.read

      final userRequest = UserRequest(
        fullName: fullName ?? currentUser.fullName,
        userName: currentUser.userName,
        email: email ?? currentUser.email,
        doB: doB ?? currentUser.doB,
        img: img,
        passwordHash: currentUser.passwordHash,
        roleId: currentUser.roleId,
      );
      print(userRequest);
      final updatedUser = await userService.updateUser(userRequest);
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    final userService = ref.read(userServiceProvider); // ✅ use ref.read
    try {
      final user = await userService.getUserData();
      state = AsyncValue.data(user);
    } catch (e) {
      print('Failed to refresh user data: $e');
      state = AsyncValue.data(null);
    }
  }
}
