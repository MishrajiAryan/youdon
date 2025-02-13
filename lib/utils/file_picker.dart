import 'package:file_picker/file_picker.dart';

Future<String?> pickDownloadFolder() async {
  String? result = await FilePicker.platform.getDirectoryPath();
  return result;
}
