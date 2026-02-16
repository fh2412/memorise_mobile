import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
}
