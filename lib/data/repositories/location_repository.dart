import 'dart:async';
import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/domain/models/location_model.dart';

class LocationRepository {
  final ApiService _apiService;

  LocationRepository(this._apiService);

  Future<int> createLocation({required MemoriseLocation location}) async {
    try {
      return await _apiService.createLocation(location);
    } catch (e) {
      print('ERROR $e');
      rethrow;
    }
  }

  Future<void> updateMemoryLocation(int memoryId, int locationId) async {
    try {
      return await _apiService.updateMemoryLocation(memoryId, locationId);
    } catch (e) {
      print('ERROR $e');
      rethrow;
    }
  }
}
