import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';

class MemoryDetailViewModel extends ChangeNotifier {
  late final MemoryRepository _memoryRepository;

  Memory? _selectedMemory;
  Memory? get selectedMemory => _selectedMemory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MemoryDetailViewModel(this._memoryRepository);

  // Method to fetch the specific memory details
  Future<void> fetchMemoryDetails(String memoryId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedMemory = null;
    notifyListeners();

    try {
      _selectedMemory = await _memoryRepository.fetchMemoryDetails(
        memoryId: memoryId,
      );
    } catch (e) {
      _errorMessage = "Could not load memory details. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
