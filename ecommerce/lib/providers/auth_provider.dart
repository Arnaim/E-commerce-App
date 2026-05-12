import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userStream;
});

final userModelProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return null;
  
  final authService = ref.watch(authServiceProvider);
  final userModel = await authService.getUserData(authState.uid);
  
  if (userModel == null) {
    // If auth exists but Firestore doc is missing, create a basic one to break the loop
    final fallbackUser = UserModel(
      uid: authState.uid,
      email: authState.email ?? '',
      displayName: authState.displayName ?? 'User',
      role: UserRole.buyer,
      createdAt: DateTime.now(),
    );
    // Attempt to save it in the background
    authService.saveUserData(fallbackUser);
    return fallbackUser;
  }
  
  return userModel;
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.login(email: email, password: password);
      final user = await _authService.getUserData(result.user!.uid);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
