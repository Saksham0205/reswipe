import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(File file, String userId) async {
    final ref = _storage.ref().child('profile_images').child('$userId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadResume(File file, String userId) async {
    final ref = _storage.ref().child('resumes').child('$userId.pdf');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}