import 'dart:io';

import 'package:memorise_mobile/data/services/upload_service.dart';

class PhotoRepository {
  final UploadService _service;

  PhotoRepository(this._service);

  Future<List<String>> uploadBatch(List<File> files, int memoryId) async {
    // We upload in parallel for better performance
    final uploadFutures = files.map(
      (file) => _service.uploadPhoto(file, memoryId),
    );
    return await Future.wait(uploadFutures);
  }
}
