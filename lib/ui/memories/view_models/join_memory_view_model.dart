import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';

class JoinMemoryViewModel extends ChangeNotifier {
  final MemoryRepository _repo;
  JoinMemoryViewModel(this._repo);

  bool isLoading = true;
  String? memoryName;
  String? inviterName;

  Future<void> loadInvite(String token) async {
    try {
      final data = await _repo.getMemoryInfoByToken(token);
      memoryName = data['memoryName'];
      inviterName = data['inviterName'];
    } catch (e) {
      // Handle error (e.g., link expired)
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptInvite(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await _repo.joinMemory(token, userId!);
      return true;
    } catch (e) {
      return false;
    }
  }
}
