import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user_model.dart';

class UserCardViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  MemoriseUser? get user => _userRepository.currentUser;
  bool get isLoading => _userRepository.isInitialLoading;

  String? error;

  UserCardViewModel(this._userRepository, this._authRepository) {
    _userRepository.addListener(notifyListeners);
    _init();
  }

  void _init() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userRepository.initializeUser(uid);
    }
  }

  @override
  void dispose() {
    _userRepository.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> logout() => _authRepository.logout();
}
