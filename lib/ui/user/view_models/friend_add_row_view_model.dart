import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/user_repository.dart';

class FriendAddViewModel extends ChangeNotifier {
  final TextEditingController codeController = TextEditingController();
  final UserRepository _userRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FriendAddViewModel(this._userRepository);

  Future<void> sendFriendRequest() async {
    final receiverCode = codeController.text.trim();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (receiverCode.isEmpty) return;

    _isLoading = true;
    _errorMessage = 'Error sending Friend request';

    final result = await _userRepository.sendFriendRequest(
      currentUserId!,
      receiverCode,
    );

    if (result.message == 'Friendship request sent successfully') {
      _errorMessage = null;
      codeController.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateCode(String code) {
    codeController.text = code;
    notifyListeners();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}
