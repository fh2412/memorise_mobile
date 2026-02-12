import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user_model.dart';

class UserCardViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  // State variables
  MemoriseUser? user;
  bool isLoading = false;
  String? error;

  UserCardViewModel(this._userRepository, this._authRepository);

  // Initial fetch called when the app starts/home loads
  Future<void> fetchUserData() async {
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    if (firebaseUid == null) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      user = await _userRepository.getUser(firebaseUid);
    } catch (e) {
      error = "Could not fetch user data: $e $user";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _authRepository.logout();
}
