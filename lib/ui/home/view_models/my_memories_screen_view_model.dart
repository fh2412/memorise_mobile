import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/auth_repository.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';

class MemoryViewModel extends ChangeNotifier {
  final MemoryRepository _repository;
  final AuthRepository _authRepository;

  MemoryViewModel(this._repository, this._authRepository);

  List<Memory> _memories = [];
  List<Memory> get memories => _memories;

  List<Memory> _filteredMemories = [];
  List<Memory> get filteredMemories =>
      _filteredMemories.isEmpty && _memories.isNotEmpty
      ? _memories
      : _filteredMemories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchMemories({
    required bool showMine,
    required bool showShared,
  }) async {
    print('FETCHING MEMORIES');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print(userId);

    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Determine the filter based on toggles
      MemoryFilter filter;
      if (showMine && showShared) {
        filter = MemoryFilter.all;
      } else if (showMine) {
        filter = MemoryFilter.created;
      } else if (showShared) {
        filter = MemoryFilter.added;
      } else {
        // If nothing is selected, we return an empty list without calling the API
        _memories = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _repository.fetchMemories(
        userId: userId,
        filter: filter,
      );

      _memories = response.data;
      _filteredMemories = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterBySearch(String query) {
    if (query.isEmpty) {
      _filteredMemories = _memories;
    } else {
      _filteredMemories = _memories
          .where(
            (m) =>
                m.title.toLowerCase().contains(query.toLowerCase()) ||
                m.text.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }
}
