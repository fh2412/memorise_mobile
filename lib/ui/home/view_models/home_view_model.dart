import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  HomeViewModel(this._repository);

  Future<void> logout() async {
    await _repository.logout();
    // We don't need to manually navigate!
    // The Router will detect the Firebase state change.
  }
}
