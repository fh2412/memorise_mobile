import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/data/services/upload_service.dart';

class PhotoRepository {
  final UploadService _uploadService;
  final ApiService _apiService;

  PhotoRepository(this._uploadService, this._apiService);

  final ValueNotifier<List<XFile>> selectedPhotosNotifier =
      ValueNotifier<List<XFile>>([]);

  List<XFile> get selectedPhotos => selectedPhotosNotifier.value;

  void addPhotos(List<XFile> newFiles) {
    selectedPhotos.addAll(newFiles);
    selectedPhotosNotifier.value = selectedPhotos;
  }

  void removePhoto(int index) {
    selectedPhotos.removeAt(index);
    selectedPhotosNotifier.value = selectedPhotos;
  }

  void clearPhotos() {
    selectedPhotosNotifier.value = [];
  }

  Future<void> uploadMemoryPhotos({
    required String memoryId,
    String? userId,
  }) async {
    // 1. Validate inputs
    if (selectedPhotosNotifier.value.isEmpty) return;

    // 2. Ensure we have a user (you could also pass this in from the VM)
    final activeUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (activeUserId == null) throw Exception("User not authenticated");

    // 3. Execute the actual sync logic
    // Assuming uploadAndSync is your low-level data provider method
    await uploadAndSync(
      memoryId: memoryId,
      files: selectedPhotosNotifier.value,
      userId: activeUserId,
    );
  }

  Future<void> uploadAndSync({
    required String memoryId,
    required List<XFile> files,
    required String userId,
  }) async {
    // 1. Upload all photos to Firebase in parallel
    final uploadTasks = files.map((file) async {
      // Get dimensions before uploading
      final image = await getImageDimensions(file);

      return _uploadService.uploadMemoryPicture(
        memoryId: memoryId,
        xFile: file,
        userId: userId,
        isStarred: false, // Defaulting to false for batch upload
        width: image.width,
        height: image.height,
      );
    });

    await Future.wait(uploadTasks);

    await _apiService.updatePictureCount(memoryId, files.length);
  }
}

Future<ui.Image> getImageDimensions(XFile xFile) async {
  final bytes = await xFile.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}
