import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<Uint8List?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return await _fileToUint8List(image);
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
    return null;
  }

  /// Capture image using camera
  static Future<Uint8List?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return await _fileToUint8List(image);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
    return null;
  }

  /// Convert XFile to Uint8List
  static Future<Uint8List> _fileToUint8List(XFile file) async {
    return await file.readAsBytes();
  }
}
