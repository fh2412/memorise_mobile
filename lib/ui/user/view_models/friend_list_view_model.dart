import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/user_model.dart';

class FriendListViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  List<Friend> userFriends = [];
  List<Friend> incomingRequests = [];
  bool isLoading = false;
  String? error;

  FriendListViewModel(this._userRepository);

  Future<void> loadAllFriendData() async {
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    if (firebaseUid == null) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _userRepository.getUserFriends(firebaseUid),
        _userRepository.getIncomingRequests(firebaseUid),
      ]);

      userFriends = results[0];
      incomingRequests = results[1];
    } catch (e) {
      error = "Getting Friend Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> handleRequest(String friendId, bool accept) async {
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    if (firebaseUid == null) return false;

    try {
      if (accept) {
        await _userRepository.acceptRequest(firebaseUid, friendId);
        final acceptedFriend = incomingRequests.firstWhere(
          (f) => f.userId == friendId,
        );
        incomingRequests.removeWhere((f) => f.userId == friendId);
        userFriends.add(acceptedFriend);
      } else {
        await _userRepository.declineRequest(firebaseUid, friendId);
        incomingRequests.removeWhere((f) => f.userId == friendId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      error = "Action failed: $e";
      notifyListeners();
      return false;
    }
  }
}
