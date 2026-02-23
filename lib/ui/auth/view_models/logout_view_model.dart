import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class LogoutViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;

  LogoutViewModel(this._authRepository);

  bool get isLoading => _isLoading;

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
