import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:memorise_mobile/domain/models/user_model.dart';

class MemoryDetailViewModel extends ChangeNotifier {
  late final MemoryRepository _memoryRepository;

  StreamSubscription<String>? _repositorySubscription;

  String? _currentMemoryId;

  Memory? _selectedMemory;
  Memory? get selectedMemory => _selectedMemory;

  List<MemoryAttendee>? _attendees;
  List<MemoryAttendee>? get attendees => _attendees;

  MemoriseUser? _creator;
  MemoriseUser? get creator => _creator;

  final userId = FirebaseAuth.instance.currentUser?.uid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MemoryDetailViewModel(this._memoryRepository) {
    _repositorySubscription = _memoryRepository.onMemoryUpdated.listen((
      updatedId,
    ) {
      if (updatedId == _currentMemoryId) {
        fetchMemoryDetails(updatedId);
      }
    });
  }

  Future<void> fetchMemoryDetails(String memoryId) async {
    _currentMemoryId = memoryId;
    _isLoading = true;
    _errorMessage = null;
    _selectedMemory = null;
    _attendees = null;
    notifyListeners();

    try {
      // 1. Fetch the memory core details
      _selectedMemory = await _memoryRepository.fetchMemoryDetails(
        memoryId: memoryId,
      );

      // 2. Fetch the attendees
      _attendees = await _memoryRepository.fetchMemoryDetailsFriends(
        userId: userId!,
        memoryId: memoryId,
      );

      final creatorId = _selectedMemory!.userId;
      _creator = await _memoryRepository.fetchMemoryCreator(userId: creatorId);
    } catch (e) {
      debugPrint(
        "Error loading memory: $e",
      ); // Always log the real error for debugging!
      _errorMessage = "Could not load memory details. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repositorySubscription?.cancel();
    super.dispose();
  }
}
