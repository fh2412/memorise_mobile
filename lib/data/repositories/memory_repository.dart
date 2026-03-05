import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:memorise_mobile/domain/models/responses.dart';

class MemoryRepository {
  final ApiService _memoryService;

  MemoryRepository(this._memoryService);

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

    return await _memoryService.getMemories(
      userId,
      endpoint,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<Memory> fetchMemoryDetails({required String memoryId}) async {
    return await _memoryService.getMemoryDetails(memoryId);
  }
}
