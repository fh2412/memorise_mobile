import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/user_repository.dart';

class MemoryInviteViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  MemoryInviteViewModel(this._userRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Placeholder for the friends list or search results
  final List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Logic for adding friends will go here
  Future<void> searchUsers(String query) async {
    setLoading(true);
    try {
      // _searchResults = await _userRepository.searchUsers(query);
    } finally {
      setLoading(false);
    }
  }
}
