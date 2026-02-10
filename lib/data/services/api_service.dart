import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  late final Dio _dio;

  // The "Localhost" trick:
  // Android emulators see 'localhost' as themselves.
  // To talk to your machine, they use '10.0.2.2'.
  static String get baseUrl {
    if (Platform.isAndroid) return "http://10.0.2.2:4200/api";
    return "http://localhost:4200/api";
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

  // Your first GET request
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return response.data;
    } on DioException catch (e) {
      // Dio gives you helpful error info (404, 500, timeout, etc.)
      throw Exception('Failed to load user: ${e.message}');
    }
  }
}
