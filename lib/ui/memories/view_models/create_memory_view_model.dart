import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/data/repositories/photo_repository.dart';
import 'package:memorise_mobile/data/services/snackbar_service.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:memorise_mobile/domain/models/location_model.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';

class MemoryCreationViewModel extends ChangeNotifier {
  final MemoryRepository _repository;
  final PhotoRepository _photoRepository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isActive = true;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedLocationName;

  List<MemoryMissingFriend> get selectedUsers => _repository.selectedUsers;

  MemoryCreationViewModel(this._repository, this._photoRepository);

  int? memoryId;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUPLoading = false;
  bool get isUPLoading => _isUPLoading;

  bool get isMetadataValid {
    return titleController.text.isNotEmpty && startDate != null;
  }

  void handleBackAction() {
    if (memoryId != null) {
      _repository.deleteMemory(memoryId.toString());
    }
    clearForm();
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    startDate = null;
    endDate = null;
    memoryId = null;
    // Clear any selected friends/photos too
    _currentStep = 0;
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  Future<void> nextStep() async {
    if (_currentStep == 0) {
      if (!isMetadataValid) {
        formKey.currentState?.validate();
        SnackBarService.show(
          'Give your Memory a Title and Date!',
          isError: false,
        );
        return;
      } else if (memoryId == null) {
        memoryId = await createBasicMemory();
        print("new memoryId is: $memoryId");
        _isLoading = false;
        notifyListeners();
        setStep(_currentStep + 1);
      } else {
        updateMemory();
        setStep(_currentStep + 1);
      }
    } else if (_currentStep == 1) {
      setStep(_currentStep + 1);
    } else if (_currentStep == 2) {
      finalizeCreation();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<int> createBasicMemory() async {
    print('Creating Memory');
    _isLoading = true;
    notifyListeners();
    final memory = CreateMemory(
      userId: FirebaseAuth.instance.currentUser!.uid,
      title: titleController.text,
      text: descriptionController.text,
      locationId: 1, //PLACEHOLDER
      memoryDate: startDate!,
      memoryEndDate: endDate ?? startDate,
      titlePic: '',
      activityId: 1,
    );
    final location = MemoriseLocation(
      latitude: 0.0,
      longitude: 0.0,
      country: '',
      countryCode: '',
      locationId: 1,
    );
    return _repository.saveMemory(
      memory: memory,
      location: location,
      isNew: true,
    );
  }

  Future<int> updateMemory() async {
    print('Updating Memory');
    _isLoading = true;
    notifyListeners();
    final memory = CreateMemory(
      userId: FirebaseAuth.instance.currentUser!.uid,
      title: titleController.text,
      text: descriptionController.text,
      locationId: 1, //PLACEHOLDER
      memoryDate: startDate!,
      memoryEndDate: endDate ?? startDate,
      titlePic: '',
      activityId: 1,
    );
    return _repository.saveMemory(
      memory: memory,
      isNew: false,
      memoryId: memoryId,
    );
  }

  Future<bool> addFriendsToMemory(
    String memoryId,
    List<MemoryMissingFriend> friendsToAdd,
  ) async {
    List<String> emails = friendsToAdd.map((friend) => friend.email).toList();
    try {
      await _repository.addFriendsToMemory(memoryId, emails);
      SnackBarService.show('You have added new Friends to the Memory!');
      return true;
    } catch (e) {
      SnackBarService.show('There was a Error adding your Friends');
      print('There was a Error adding your Friends $e');
      return false;
    } finally {
      _repository.clearSelectedUsers();
    }
  }

  Future<void> executeUpload(int memoryId) async {
    try {
      await _photoRepository.uploadMemoryPhotos(
        memoryId: memoryId.toString(),
        isNew: true,
      );

      _photoRepository.clearPhotos();
      SnackBarService.show("Memories uploaded successfully!");
    } catch (e) {
      SnackBarService.show("Upload failed: $e", isError: true);
    } finally {
      _isUPLoading = false;
      notifyListeners();
    }
  }

  Future<bool> finalizeCreation() async {
    if (memoryId == null) return false;

    _isUPLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        addFriendsToMemory(memoryId.toString(), selectedUsers),
        executeUpload(memoryId!),
      ]);

      _repository.clearSelectedUsers();
      _photoRepository.clearPhotos();

      return true;
    } catch (e) {
      debugPrint("Finalize Error: $e");
      return false;
    } finally {
      _isUPLoading = false;
      notifyListeners();
    }
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
