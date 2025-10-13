// Web-only implementation: avoid dart:io entirely
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  // Use this on web (or any platform) when you have the file bytes
  Future<String> uploadBytes(
    Uint8List data,
    String fileName,
    String? extension,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '${timestamp}_$fileName';
    final storageRef = FirebaseStorage.instance.ref().child('images/$uniqueFileName');
    SettableMetadata metadata = SettableMetadata(contentType: 'image/$extension');
    final uploadTask = storageRef.putData(data, metadata);

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteFile(String fileUrl) async {
      final storageRef = FirebaseStorage.instance.refFromURL(fileUrl);
      await storageRef.delete();
    
  }
}
