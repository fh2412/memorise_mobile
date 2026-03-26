import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:memorise_mobile/domain/models/responses.dart';
import 'package:memorise_mobile/domain/models/user_model.dart';

class MemoryRepository {
  final ApiService _apiService;

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

  Future<List<MemoryMissingFriend>> getMemoryMissingFriends(
    String userId,
    String memoryId,
  ) async {
    // Calling your API service
    return await _apiService.getMemoryMissingFriends(userId, memoryId);
  }
}
