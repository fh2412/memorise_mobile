import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:memorise_mobile/domain/models/location_model.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:memorise_mobile/domain/models/responses.dart';

class ApiService {
  late final Dio _dio;

  static String get baseUrl {
    // kIsWeb is a boolean that is true when running in a browser
    if (kIsWeb) {
      return "http://localhost:3000/api";
    } else {
      // We only check for Android if we aren't on the web
      // To avoid the error, we assume 10.0.2.2 for mobile emulators
      return "http://10.0.2.2:4200/api";
    }
  }

  ApiService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));

    // Add an Interceptor for the Auth Header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Continue request
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to load user: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> sendFriendRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      final response = await _dio.post(
        '/friends/send_request',
        data: {'senderId': senderId, 'receiverId': receiverId},
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to load user: ${e.message}');
    }
  }

  Future<List<dynamic>> getUserFriends(String userId) async {
    try {
      final response = await _dio.get('/friends/$userId');
      return response.data as List;
    } on DioException catch (e) {
      throw Exception('Failed to load friends: ${e.message}');
    }
  }

  Future<List<dynamic>> getIncomingRequests(String userId) async {
    try {
      final response = await _dio.get('/friends/ingoing/$userId');
      return response.data as List;
    } on DioException catch (e) {
      throw Exception('Failed to load requests: ${e.message}');
    }
  }

  Future<void> acceptFriendRequest(String userId, String friendId) async {
    await _dio.put('/friends/accept_request/$userId/$friendId');
  }

  Future<void> declineFriendRequest(String userId, String friendId) async {
    await _dio.delete('/friends/remove_friend/$userId/$friendId');
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _dio.put('/users/mobile/$userId', data: data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? "Failed to update user";
    }
  }

  Future<PaginatedMemoryResponse> getMemories(
    String userId,
    String endpoint, {
    int page = 0,
    int pageSize = 9,
  }) async {
    try {
      final response = await _dio.get(
        '$endpoint/$userId',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      // Using your existing PaginatedMemoryResponse model
      return PaginatedMemoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load memories: ${e.message}');
    }
  }

  Future<Memory> getMemoryDetails(String memoryId) async {
    try {
      final response = await _dio.get('/memories/$memoryId');

      return Memory.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load memory details: ${e.message}');
    }
  }

  Future<List<MemoryAttendee>> getMemoryDetailsFriends(
    String userId,
    String memoryId,
  ) async {
    try {
      final response = await _dio.get('/memories/$memoryId/$userId/friends');
      if (response.data is List) {
        return (response.data as List)
            .map(
              (item) => MemoryAttendee.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      return []; // Return empty list if data is unexpectedly not a list
    } on DioException catch (e) {
      throw Exception('Failed to load memory friends: ${e.message}');
    }
  }

  Future<void> updatePictureCount(String memoryId, int incrementBy) async {
    try {
      await _dio.post(
        '/memories/picturecount/$memoryId/increment',
        data: {'increment': incrementBy},
      );
    } on DioException catch (e) {
      debugPrint("API Error: ${e.response?.data}");
      throw e.response?.data['message'] ?? "Failed to update picture count";
    }
  }

  Future<String> getMemoryInviteToken(String memoryId) async {
    try {
      final response = await _dio.get('/invite/$memoryId');
      final data = response.data as Map<String, dynamic>;
      return data['inviteLink'] as String;
    } on DioException catch (e) {
      throw Exception('Failed to get memory invite: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getMemoryInfoByToken(String token) async {
    try {
      final response = await _dio.get('/invite/info/$token');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Invalid or expired invite link: $e');
    }
  }

  Future<void> joinMemory(String token, String userId) async {
    await _dio.post('/invite/join/$token', data: {'userId': userId});
  }

  Future<void> addFriendsToMemory(String memoryId, List<String> emails) async {
    await _dio.post(
      '/memories/addFriendsToMemory',
      data: {'emails': emails, 'memoryId': memoryId},
    );
  }

  Future<List<MemoryMissingFriend>> getMemoryMissingFriends(
    String userId,
    String memoryId,
  ) async {
    try {
      final response = await _dio.get(
        '/friends/missingMemory/$memoryId/$userId/',
      );
      if (response.data is List) {
        return (response.data as List)
            .map(
              (item) =>
                  MemoryMissingFriend.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load memory missing friends: ${e.message}');
    }
  }

  Future<int> createMemory(CreateMemory memory) async {
    final response = await _dio.post(
      '/memories/createMemory',
      data: {
        'creator_id': memory.userId,
        'title': memory.title,
        'description': memory.text,
        'location_id': memory.locationId,
        'memory_date': memory.memoryDate.toIso8601String(),
        'memory_end_date': memory.memoryEndDate?.toIso8601String(),
        'title_pic': memory.titlePic,
        'activity_id': memory.activityId,
      },
    );
    final data = response.data as Map<String, dynamic>;
    print(data);
    return data['memory_id'] as int;
  }

  Future<void> updateMemory(CreateMemory memory, String memoryId) async {
    await _dio.put(
      '/memories/$memoryId',
      data: {
        'title': memory.title,
        'description': memory.text,
        'memory_date': memory.memoryDate.toIso8601String(),
        'memory_end_date': memory.memoryEndDate?.toIso8601String(),
      },
    );
  }

  Future<void> createLocation(MemoriseLocation location) async {
    final locationId = await _dio.post(
      '/locations/createLocation',
      data: {
        'country': location.country,
        'countryCode': location.countryCode,
        'city': location.city,
        'latitude': location.latitude,
        'longitude': location.latitude,
      },
    );
    return locationId.data;
  }

  Future<void> deleteMemory(String memoryId) async {
    await _dio.delete('/memories/$memoryId');
  }
}
