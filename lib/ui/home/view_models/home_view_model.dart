import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  // State variables
  bool isLoading = false;
  String? error;

  HomeViewModel(this._authRepository);

  Future<void> logout() => _authRepository.logout();
}
