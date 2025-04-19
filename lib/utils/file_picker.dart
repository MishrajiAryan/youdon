// file_picker.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart'; // Make sure you have this package

Future<String?> pickDownloadFolder() async {
  try {
    String? directory = await FilePicker.platform.getDirectoryPath();
    return directory;
    } catch (e) {
    // Handle exceptions (permissions, etc.)
    debugPrint("Error picking directory: $e");
    return null;
  }
}
