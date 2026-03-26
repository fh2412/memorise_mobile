import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';

class MemoryInviteViewModel extends ChangeNotifier {
  final MemoryRepository _memoryRepository;
  MemoryInviteViewModel(this._memoryRepository);

  List<MemoryMissingFriend> _allPotentialFriends = [];

  List<MemoryMissingFriend> _filteredFriends = [];
  List<MemoryMissingFriend> get filteredFriends => _filteredFriends;

  final List<MemoryMissingFriend> _selectedUsers = [];
  List<MemoryMissingFriend> get selectedUsers => _selectedUsers;

  String? _inviteToken;
  String? get inviteToken => _inviteToken;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isTokenLoading = false;
  bool get isTokenLoading => _isTokenLoading;

  final userId = FirebaseAuth.instance.currentUser?.uid;

  bool get hasNoPotentialFriends => !_isLoading && _allPotentialFriends.isEmpty;
  bool get hasNoSearchResults =>
      !_isLoading &&
      _allPotentialFriends.isNotEmpty &&
      _filteredFriends.isEmpty;

  Future<void> fetchPotentialFriends(String memoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _allPotentialFriends = await _memoryRepository.getMemoryMissingFriends(
        userId!,
        memoryId,
      );
      _filteredFriends = _allPotentialFriends;
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredFriends = _allPotentialFriends;
    } else {
      _filteredFriends = _allPotentialFriends.where((user) {
        final nameMatch = user.name.toLowerCase().contains(query.toLowerCase());
        final emailMatch = user.email.toLowerCase().contains(
          query.toLowerCase(),
        );
        return nameMatch || emailMatch;
      }).toList();
    }
    notifyListeners();
  }

  void toggleUserSelection(MemoryMissingFriend user) {
    if (_selectedUsers.any((u) => u.userId == user.userId)) {
      _selectedUsers.removeWhere((u) => u.userId == user.userId);
    } else {
      _selectedUsers.add(user);
    }
    notifyListeners();
  }

  Future<void> fetchInviteToken(String memoryId) async {
    // Only fetch if we don't have one yet
    if (_inviteToken != null || _isTokenLoading) return;

    _isTokenLoading = true;
    notifyListeners();

    try {
      _inviteToken = await _memoryRepository.getInviteToken(memoryId);
    } catch (e) {
      debugPrint("Error fetching token: $e");
    } finally {
      _isTokenLoading = false;
      notifyListeners();
    }
  }
}
