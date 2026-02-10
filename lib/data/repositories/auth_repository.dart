import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  Future<User?> login(String email, String password) async {
    final credential = await _authService.signIn(email, password);
    return credential.user;
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
