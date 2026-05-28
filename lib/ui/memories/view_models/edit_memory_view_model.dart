import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';

class EditMemoryViewModel extends ChangeNotifier {
  final MemoryRepository _memoryRepository;

  // Controllers
  final titleController = TextEditingController();
  final textController = TextEditingController();

  // State Variables
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DateTime? get selectedStartDate => _selectedStartDate;
  DateTime? get selectedEndDate => _selectedEndDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EditMemoryViewModel(this._memoryRepository);

  /// Initializes the View Model with existing data from the selected memory
  void init(Memory memory) {
    _errorMessage = null;
    _isLoading = false;

    titleController.text = memory.title;
    textController.text = memory.text;
    _selectedStartDate = memory.memoryDate;
    _selectedEndDate = memory.memoryEndDate;

    notifyListeners();
  }

  /// Updates the start date and clears error state
  void updateStartDate(DateTime date) {
    _selectedStartDate = date;
    _errorMessage = null;

    // Basic validation: Ensure end date isn't before the new start date
    if (_selectedEndDate != null && _selectedEndDate!.isBefore(date)) {
      _selectedEndDate = date;
    }

    notifyListeners();
  }

  /// Updates the end date and clears error state
  void updateEndDate(DateTime date) {
    _selectedEndDate = date;
    _errorMessage = null;
    notifyListeners();
  }

  /// Handles updating the memory via your repository or API layer
  Future<bool> saveMemory(int memoryId) async {
    // 1. Basic validation check
    if (titleController.text.trim().isEmpty) {
      _errorMessage = "Title cannot be empty.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // TODO: Inject your MemoryRepository / API Service and call update here
      // e.g., await _memoryRepository.updateMemory(memoryId, title: titleController.text, ...);

      await Future.delayed(
        const Duration(seconds: 1),
      ); // Mocking network latency

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = "Failed to save memory: ${e.toString()}";
      return false;
    }
  }

  /// Handles deleting the memory via your repository or API layer
  Future<bool> deleteMemory(int memoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _memoryRepository.completeMemoryDeletion(memoryId: memoryId);

      _isLoading = false;
      notifyListeners();
      return true; // Execution cleared successfully
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to completely delete memory: ${e.toString()}";
      notifyListeners();
      return false; // Execution failed
    }
  }

  /// Helper to change loading state and refresh UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    super.dispose();
  }
}
