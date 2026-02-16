import 'package:memorise_mobile/domain/models/responses.dart';

import '../../domain/models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<MemoriseUser> getUser(String userId) async {
    final Map<String, dynamic> rawData = await _apiService.getUserData(userId);
    return MemoriseUser.fromJson(rawData);
  }

  Future<InsertStandardResult> sendFriendRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      final data = await _apiService.sendFriendRequest(senderId, receiverId);
      return InsertStandardResult.fromJson(data);
    } catch (e) {
      return InsertStandardResult(message: 'Error sending friend request');
    }
  }
}
