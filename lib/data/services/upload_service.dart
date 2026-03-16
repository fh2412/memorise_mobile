import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMemoryPicture({
    required String memoryId,
    required XFile xFile,
    required String userId,
    required bool isStarred,
    required int width,
    required int height,
  }) async {
    // Unique ID logic matching your Angular code
    final randomStr = Random().nextInt(1000000).toString().padLeft(9, '0');
    final uniqueId = '${DateTime.now().millisecondsSinceEpoch}_$randomStr';
    final path = 'memories/$memoryId/$uniqueId.jpg';
    final storageRef = _storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'width': width.toString(),
        'height': height.toString(),
        'isStarred': isStarred.toString(),
        'userId': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    TaskSnapshot snapshot;
    if (kIsWeb) {
      snapshot = await storageRef.putData(await xFile.readAsBytes(), metadata);
    } else {
      snapshot = await storageRef.putFile(File(xFile.path), metadata);
    }

    return await snapshot.ref.getDownloadURL();
  }
}
