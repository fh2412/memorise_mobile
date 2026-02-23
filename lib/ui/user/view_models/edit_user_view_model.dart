import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/user_repository.dart';

class EditUserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  DateTime? selectedDob;
  String? selectedGender;

  bool isLoading = false;
  String? errorMessage;

  EditUserViewModel(this._userRepository);

  // Call this when opening the dialog to fill existing data
  void init(Map<String, dynamic> currentData) {
    nameController.text = currentData['name'] ?? "";
    bioController.text = currentData['bio'] ?? "";
    selectedDob = DateTime.tryParse(currentData['dob'] ?? "");
    selectedGender = currentData['gender'];
    errorMessage = null;
    notifyListeners();
  }

  void updateDob(DateTime dob) {
    selectedDob = dob;
    notifyListeners();
  }

  void updateGender(String? gender) {
    selectedGender = gender;
    notifyListeners();
  }

  Future<bool> saveUser(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.updateUserData(userId, {
        'name': nameController.text,
        'bio': bioController.text,
        'dob': selectedDob?.toIso8601String(),
        'gender': selectedGender,
      });
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
