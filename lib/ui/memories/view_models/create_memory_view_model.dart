import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';

class MemoryCreationViewModel extends ChangeNotifier {
  final MemoryRepository _repository;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isActive = true;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedLocationName;

  MemoryCreationViewModel(this._repository);

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isMetadataValid {
    return titleController.text.isNotEmpty && startDate != null;
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep(int totalSteps) {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    } else {
      _submitMemory();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<void> _submitMemory() async {
    _isLoading = true;
    notifyListeners();
    // API call logic...
    _isLoading = false;
    notifyListeners();
  }

  // --- Form Methods ---
  void updateIsActive(bool? value) {
    isActive = value ?? true;
    notifyListeners();
  }

  void updateStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void updateEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void setLocation(String name) {
    selectedLocationName = name;
    notifyListeners();
  }

  Future<void> fetchCurrentLocation() async {
    // Logic for GPS will go here
    setLocation("Current GPS Location");
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
