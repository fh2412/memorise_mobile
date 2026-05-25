import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Replicates your listAll -> forkJoin(deleteObject) logic
  Future<void> deleteMemoryFolder(int memoryId) async {
    final path = 'memories/$memoryId';
    final storageRef = _storage.ref().child(path);

    try {
      // 1. Fetch all items inside the directory
      final listResult = await storageRef.listAll();

      if (listResult.items.isEmpty) {
        return; // Empty folder, resolve early
      }

      // TODO: If you need to replicate your billing notification stream:
      // await _processAndNotifyBilling(listResult.items);

      // 2. Map items to individual delete futures (Equivalent to forkJoin)
      final deleteTasks = listResult.items.map((item) => item.delete());

      // 3. Execute all deletions concurrently
      await Future.wait(deleteTasks);

      print('Folder $path deleted successfully.');
    } catch (e) {
      throw Exception('Failed to clear storage directory: $e');
    }
  }
}
