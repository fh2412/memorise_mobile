import '../../domain/models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<MemoriseUser> getUser(String userId) async {
    // 1. Fetch raw Map data from Service
    final Map<String, dynamic> rawData = await _apiService.getUserData(userId);

    // 2. Map the raw JSON to our Dart Model
    return MemoriseUser.fromJson(rawData);
  }
}
