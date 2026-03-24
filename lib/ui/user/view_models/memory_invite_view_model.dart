import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';

class MemoryInviteViewModel extends ChangeNotifier {
  final MemoryRepository _memoryRepository;
  MemoryInviteViewModel(this._memoryRepository);

  String? _inviteToken;
  String? get inviteToken => _inviteToken;

  bool _isTokenLoading = false;
  bool get isTokenLoading => _isTokenLoading;

  Future<void> fetchInviteToken(String memoryId) async {
    // Only fetch if we don't have one yet
    if (_inviteToken != null || _isTokenLoading) return;

    _isTokenLoading = true;
    notifyListeners();

    try {
      _inviteToken = await _memoryRepository.getInviteToken(memoryId);
    } catch (e) {
      debugPrint("Error fetching token: $e");
    } finally {
      _isTokenLoading = false;
      notifyListeners();
    }
  }
}
