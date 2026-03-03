import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';

class MemoryViewModel extends ChangeNotifier {
  final MemoryRepository _repository;
  final String userId;

  MemoryViewModel({required MemoryRepository repository, required this.userId})
    : _repository = repository;

  List<Memory> _memories = [];
  List<Memory> get memories => _memories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Fetch memories based on the two boolean toggles from the UI
  Future<void> fetchMemories({
    required bool showMine,
    required bool showShared,
  }) async {
    _isLoading = true;
    _error = null;
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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
