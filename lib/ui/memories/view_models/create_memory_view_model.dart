import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';

class MemoryCreationViewModel extends ChangeNotifier {
  final MemoryRepository _repository;

  MemoryCreationViewModel(this._repository);

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Draft Data
  String title = '';
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedFriends = [];
  List<String> photoPaths = [];

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    } else {
      submitMemory();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<void> submitMemory() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Logic to construct your Memory and Location objects from draft data
      // await _repository.saveMemory(memory: ..., location: ...);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
