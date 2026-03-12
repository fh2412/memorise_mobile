import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/photo_model.dart';

class PhotoGalleryViewModel extends ChangeNotifier {
  List<MemoryPhoto> _images = [];
  List<MemoryPhoto> get images => _images;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchMemoryPhotos(String imageId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        "memories/$imageId",
      );
      final res = await storageRef.listAll();

      _images = await Future.wait(
        res.items.map((itemRef) async {
          final url = await itemRef.getDownloadURL();
          final metadata = await itemRef.getMetadata();
          final custom = metadata.customMetadata ?? {};

          return MemoryPhoto(
            url: url,
            width: double.tryParse(custom['width'] ?? '3000') ?? 3000,
            height: double.tryParse(custom['height'] ?? '4000') ?? 4000,
            userId: custom['userId'] ?? '',
            isStarred: custom['isStarred'] == 'true',
            timeCreated: metadata.timeCreated?.toIso8601String(),
            size: metadata.size,
          );
        }).toList(),
      );
    } on FirebaseException catch (e) {
      debugPrint("Failed with error '${e.code}': ${e.message}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
