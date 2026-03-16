import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';
import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/data/services/upload_service.dart';

class PhotoRepository {
  final UploadService _uploadService;
  final ApiService _apiService;

  PhotoRepository(this._uploadService, this._apiService);

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
