import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:memorise_mobile/domain/models/location_model.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:memorise_mobile/domain/models/responses.dart';
import 'package:memorise_mobile/domain/models/user_model.dart';

class MemoryRepository {
  final ApiService _apiService;

  final ValueNotifier<List<MemoryMissingFriend>> selectedUsersNotifier =
      ValueNotifier<List<MemoryMissingFriend>>([]);

  List<MemoryMissingFriend> get selectedUsers => selectedUsersNotifier.value;

  final _memoryUpdateController = StreamController<String>.broadcast();
  Stream<String> get onMemoryUpdated => _memoryUpdateController.stream;

  MemoryRepository(this._apiService);

  Future<PaginatedMemoryResponse> fetchMemories({
    required String userId,
    required MemoryFilter filter,
    int page = 0,
    int pageSize = 50,
  }) async {
    String endpoint;

    // Logic to determine the correct route
    switch (filter) {
      case MemoryFilter.all:
        endpoint = '/memories/all';
        break;
      case MemoryFilter.created:
        endpoint = '/memories/createdMemories';
        break;
      case MemoryFilter.added:
        endpoint = '/memories/addedMemories';
        break;
    }

    return await _apiService.getMemories(
      userId,
      endpoint,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<Memory> fetchMemoryDetails({required String memoryId}) async {
    return await _apiService.getMemoryDetails(memoryId);
  }

  Future<List<MemoryAttendee>> fetchMemoryDetailsFriends({
    required String userId,
    required String memoryId,
  }) async {
    try {
      // Calling the API service method updated above
      return await _apiService.getMemoryDetailsFriends(userId, memoryId);
    } catch (e) {
      // Re-throw or handle repository-specific logging here
      rethrow;
    }
  }

  Future<MemoriseUser> fetchMemoryCreator({required String userId}) async {
    final Map<String, dynamic> rawData = await _apiService.getUserData(userId);
    return MemoriseUser.fromJson(rawData);
  }

  Future<String> getInviteToken(String memoryId) async {
    return await _apiService.getMemoryInviteToken(memoryId);
  }

  Future<Map<String, dynamic>> getMemoryInfoByToken(String token) async {
    return await _apiService.getMemoryInfoByToken(token);
  }

  Future<void> joinMemory(String token, String userId) async {
    await _apiService.joinMemory(token, userId);
  }

  Future<void> addFriendsToMemory(String memoryId, List<String> emails) async {
    await _apiService.addFriendsToMemory(memoryId, emails);
    _memoryUpdateController.add(memoryId);
  }

  Future<List<MemoryMissingFriend>> getMemoryMissingFriends(
    String userId,
    String memoryId,
  ) async {
    // Calling your API service
    return await _apiService.getMemoryMissingFriends(userId, memoryId);
  }

  Future<int> saveMemory({
    required CreateMemory memory,
    MemoriseLocation? location,
    required bool isNew,
    int? memoryId,
  }) async {
    try {
      // 1. Create the location first
      //await _apiService.createLocation(location);

      // 2. Create the memory
      // Note: In a real scenario, you'd likely get a locationId back
      // from the createLocation call to pass into the memory object.
      if (isNew) {
        return await _apiService.createMemory(memory);
      } else if (memoryId != null) {
        await _apiService.updateMemory(memory, memoryId.toString());
      }
      return memoryId ?? 0;
    } catch (e) {
      print('ERROR $e');
      rethrow;
    }
  }

  Future<void> deleteMemory(String memoryId) {
    return _apiService.deleteMemory(memoryId);
  }

  void toggleUserSelection(MemoryMissingFriend user) {
    final currentList = List<MemoryMissingFriend>.from(
      selectedUsersNotifier.value,
    );

    if (currentList.any((u) => u.userId == user.userId)) {
      currentList.removeWhere((u) => u.userId == user.userId);
    } else {
      currentList.add(user);
    }

    selectedUsersNotifier.value = currentList;
  }

  void clearSelectedUsers() {
    selectedUsersNotifier.value = [];
  }

  void dispose() {
    _memoryUpdateController.close();
  }
}
