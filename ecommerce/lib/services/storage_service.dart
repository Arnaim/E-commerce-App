import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(String sellerId, File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('products').child(sellerId).child(fileName);
    
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    
    return await snapshot.ref.getDownloadURL();
  }

  Future<List<String>> uploadProductImages(String sellerId, List<File> imageFiles) async {
    List<String> urls = [];
    for (var file in imageFiles) {
      String url = await uploadProductImage(sellerId, file);
      urls.add(url);
    }
    return urls;
  }

  Future<void> deleteImage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      // Handle or ignore error if image already deleted
    }
  }
}
