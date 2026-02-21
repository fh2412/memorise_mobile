import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/user_model.dart';

class UserScreenViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  MemoriseUser? user;
  bool isLoading = false;
  String? error;

  UserScreenViewModel(this._userRepository);

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
}
