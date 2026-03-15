import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/photo_repository.dart';
import 'package:image_picker/image_picker.dart';

class UploadViewModel extends ChangeNotifier {
  final PhotoRepository _repository;

  UploadViewModel(this._repository);
  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedPhotos = [];
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

    try {
      // Pass XFiles to the repository
      await _repository.uploadBatch(_selectedPhotos.cast<File>(), memoryId);
      _selectedPhotos.clear();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
