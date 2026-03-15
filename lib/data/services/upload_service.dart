import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPhoto(File file, int memoryId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('memories/$memoryId/$fileName');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
