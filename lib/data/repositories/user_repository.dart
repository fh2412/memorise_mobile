import 'package:flutter/widgets.dart';
import 'package:memorise_mobile/domain/models/responses.dart';

import '../../domain/models/user_model.dart';
import '../services/api_service.dart';

class UserRepository extends ChangeNotifier {
  final ApiService _apiService;
  MemoriseUser? _cachedUser;
  bool _isInitialLoading = true;

  UserRepository(this._apiService);

  MemoriseUser? get currentUser => _cachedUser;
  bool get isInitialLoading => _isInitialLoading;

  Future<void> initializeUser(String userId) async {
    try {
      final Map<String, dynamic> rawData = await _apiService.getUserData(
        userId,
      );
      _cachedUser = MemoriseUser.fromJson(rawData);
    } catch (e) {
      print("Init error: $e");
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<MemoriseUser> getUser(String userId) async {
    final Map<String, dynamic> rawData = await _apiService.getUserData(userId);
    notifyListeners();
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

  Future<List<Friend>> getUserFriends(String userId) async {
    final List<dynamic> rawData = await _apiService.getUserFriends(userId);
    return rawData.map((json) => Friend.fromJson(json)).toList();
  }

  Future<List<Friend>> getIncomingRequests(String userId) async {
    final List<dynamic> rawData = await _apiService.getIncomingRequests(userId);
    return rawData.map((json) => Friend.fromJson(json)).toList();
  }

  Future<void> acceptRequest(String userId, String friendId) =>
      _apiService.acceptFriendRequest(userId, friendId);

  Future<void> declineRequest(String userId, String friendId) =>
      _apiService.declineFriendRequest(userId, friendId);

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await _apiService.updateUser(userId, data);
    await getUser(userId);
  }
}
