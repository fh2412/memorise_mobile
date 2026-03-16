import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/photo_repository.dart';
import 'package:image_picker/image_picker.dart';

class UploadViewModel extends ChangeNotifier {
  final PhotoRepository _repository;

  UploadViewModel(this._repository);
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _selectedPhotos = [];
  bool _isUploading = false;

  List<XFile> get selectedPhotos => _selectedPhotos;
  bool get isUploading => _isUploading;

  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _selectedPhotos.addAll(pickedFiles);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _selectedPhotos.removeAt(index);
    notifyListeners();
  }

  Future<void> submitMemories(int memoryId) async {
    if (_selectedPhotos.isEmpty) return;

    _isUploading = true;
    notifyListeners();

    final userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      await _repository.uploadAndSync(
        memoryId: memoryId.toString(),
        files: _selectedPhotos,
        userId: userId!,
      );
      _selectedPhotos.clear();
      // You could trigger a success message or navigation here
    } catch (e) {
      // Handle error (e.g., show a SnackBar in the View)
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
