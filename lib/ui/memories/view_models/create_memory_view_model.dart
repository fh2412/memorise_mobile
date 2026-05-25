import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:memorise_mobile/data/repositories/location_repository.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/data/repositories/photo_repository.dart';
import 'package:memorise_mobile/data/services/location_service.dart';
import 'package:memorise_mobile/data/services/snackbar_service.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:memorise_mobile/domain/models/google_places_model.dart';
import 'package:memorise_mobile/domain/models/location_model.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';

class MemoryCreationViewModel extends ChangeNotifier {
  final MemoryRepository _repository;
  final PhotoRepository _photoRepository;
  final LocationRepository _locationRepository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isActive = true;
  DateTime? startDate;
  DateTime? endDate;

  String? selectedLocationName;
  MemoriseLocation? _selectedLocation;
  final TextEditingController locationController = TextEditingController();

  List<MemoryMissingFriend> get selectedUsers => _repository.selectedUsers;

  MemoryCreationViewModel(
    this._repository,
    this._photoRepository,
    this._locationRepository,
  );

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

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Timer? _debounce;

  void handleBackAction() {
    _repository.deleteMemory(memoryId!);
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
    print(
      "Selected Location: lat: ${_selectedLocation!.latitude}, lng: ${_selectedLocation!.longitude}, country: ${_selectedLocation!.country}, , countryCode: ${_selectedLocation!.countryCode}, , city: ${_selectedLocation!.city}",
    );

    return _repository.saveMemory(memory: memory, isNew: true);
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

  Future<bool> createAndAddLocation(MemoriseLocation location) async {
    try {
      final locationId = await _locationRepository.createLocation(
        location: location,
      );
      await _locationRepository.updateMemoryLocation(memoryId!, locationId);
      print("Location $locationId was added to Memory $memoryId");
      return true;
    } catch (e) {
      SnackBarService.show('There was a Error adding the Location');
      print('There was a Error adding the Location $e');
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
        createAndAddLocation(_selectedLocation!),
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

  void setLocation(MemoriseLocation location) {
    _selectedLocation = location;
    selectedLocationName = location.address;
    locationController.text = location.address;
    notifyListeners();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();
      if (position != null) {
        // Use geocoding to get the address from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        Placemark place = placemarks.first;

        setLocation(
          MemoriseLocation(
            locationId: 0,
            latitude: position.latitude,
            longitude: position.longitude,
            address: "${place.street}, ${place.postalCode} ${place.locality}",
            country: place.country ?? '',
            countryCode: place.isoCountryCode ?? '',
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<PlacePrediction>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    Completer<List<PlacePrediction>> completer = Completer();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _setSearching(true);
      try {
        final results = await _repository.getAutocomplete(query);
        completer.complete(results);
      } catch (e) {
        completer.complete([]);
      } finally {
        _setSearching(false);
      }
    });

    return completer.future;
  }

  Future<void> selectPlace(PlacePrediction prediction) async {
    try {
      final locationDetails = await _repository.getPlaceDetails(
        prediction.placeId,
      );

      setLocation(locationDetails);
    } catch (e) {
      debugPrint("Error fetching details: $e");
    }
  }

  void _setSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
