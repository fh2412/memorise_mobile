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
    required bool isNew,
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
      isNew: isNew,
    );
  }

  Future<void> uploadAndSync({
    required String memoryId,
    required List<XFile> files,
    required String userId,
    required bool isNew,
  }) async {
    if (files.isEmpty) return;

    // 1. Prepare upload tasks
    // We use .asMap() to identify the first index (0)
    final uploadTasks = files.asMap().entries.map((entry) async {
      final int index = entry.key;
      final XFile file = entry.value;
      final bool isFirst = index == 0 && isNew;

      final image = await getImageDimensions(file);

      // Assuming uploadMemoryPicture returns the download URL String
      return _uploadService.uploadMemoryPicture(
        memoryId: memoryId,
        xFile: file,
        userId: userId,
        isStarred: isFirst, // First image gets starred
        width: image.width,
        height: image.height,
      );
    });

    // 2. Wait for all uploads to complete and collect URLs
    final List<String> uploadedUrls = await Future.wait(uploadTasks);

    // 3. Update the title picture using the first URL
    if (uploadedUrls.isNotEmpty && isNew) {
      await _apiService.updateTitlePic(uploadedUrls.first, memoryId);
    }

    // 4. Sync the total count
    await _apiService.updatePictureCount(memoryId, files.length);
  }
}

Future<ui.Image> getImageDimensions(XFile xFile) async {
  final bytes = await xFile.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}
