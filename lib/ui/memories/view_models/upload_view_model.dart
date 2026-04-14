import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memorise_mobile/data/repositories/photo_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorise_mobile/data/services/snackbar_service.dart';

class UploadViewModel extends ChangeNotifier {
  final PhotoRepository _repository;

  UploadViewModel(this._repository) {
    _repository.selectedPhotosNotifier.addListener(notifyListeners);
  }
  final ImagePicker _picker = ImagePicker();

  List<XFile> get selectedPhotos => _repository.selectedPhotos;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _repository.addPhotos(pickedFiles);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _repository.removePhoto(index);
    notifyListeners();
  }

  void clearPhotos() {
    _repository.clearPhotos();
  }

  Future<void> executeUpload(int memoryId) async {
    _isUploading = true;
    notifyListeners();

    try {
      await _repository.uploadMemoryPhotos(
        memoryId: memoryId.toString(),
        isNew: false,
      );

      _repository.clearPhotos();
      SnackBarService.show("Memories uploaded successfully!");
    } catch (e) {
      SnackBarService.show("Upload failed: $e", isError: true);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.selectedPhotosNotifier.removeListener(notifyListeners);
    super.dispose();
  }
}
