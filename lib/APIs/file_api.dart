import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

Future<void> pickFiles(String folderPath) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

  for(int i=0; i<result!.files.length; i++){
    await saveFile(result.files[i], folderPath);
  }
}

Future<String> getAppDirectory() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<void> saveFile(PlatformFile file, String folderPath) async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  if (file.path == null) {
    // Handle the case where the file.path is null
    return;
  }

  final appDir = await getAppDirectory();
  //final newFilePath = '$appDir/${file.name}';
  final newFilePath = folderPath.isEmpty ? '$appDir/${file.name}' : '$folderPath/${file.name}';

  final newFile = File(newFilePath);
  await newFile.writeAsBytes(await File(file.path!).readAsBytes());

  // Save the file path to secure storage
  await secureStorage.write(key: file.name, value: newFilePath);
}

/*Future<List<String>> getSavedFiles() async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  final allKeys = await secureStorage.readAll();
  return allKeys.values.toList();
}*/

Future<List<String>> getSavedFilesAndFolders(String folderPath) async {
  final directory = await getApplicationDocumentsDirectory();
  String directoryPath = '';
  if(folderPath == ''){
    directoryPath = directory.path;
    /*const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    final allKeys = await secureStorage.readAll();
    return allKeys.values.toList();*/
  }
  else{
    directoryPath = folderPath;
  }

  print(directoryPath);
  final directoryContents = Directory(directoryPath).listSync();

  final paths = directoryContents.map((entity) => entity.path).toList();
  return paths;
  print(directoryPath);

  //final directoryPath = folderPath; //${directory.path}/ok

}

/*Stream<List<String>> getSavedFilesStream() async* {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  final allKeys = await secureStorage.readAll();
  List<String> filePaths = [];

  for (var file in allKeys.values) {
    filePaths.add(file);
    yield filePaths; // Yield the list with the new file added
    ///await Future.delayed(const Duration(milliseconds: 500)); // Optional delay for demo purposes
  }
}*/

Future<void> deleteFile(String fileName) async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Retrieve the file path from secure storage
  final filePath = await secureStorage.read(key: fileName);

  if (filePath == null) {
    // Handle the case where the file path is not found in secure storage
    return;
  }

  final file = File(filePath);

  if (await file.exists()) {
    await file.delete();
    await secureStorage.delete(key: fileName);
  }
}

Future<void> exportFileToDownloads(String fileName) async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Retrieve the file path from secure storage
  final filePath = await secureStorage.read(key: fileName);

  if (filePath == null) {
    // Handle the case where the file path is not found in secure storage
    return;
  }

  final file = File(filePath);

  if (await file.exists()) {
    // Obtain the global Downloads directory
    final downloadsDir = Directory('/storage/emulated/0/Download');

    // Check if the directory exists
    if (await downloadsDir.exists()) {
      final newFilePath = '${downloadsDir.path}/$fileName';

      // Copy the file to the global Downloads directory
      await file.copy(newFilePath);
    } else {
      print('Downloads directory does not exist');
    }
  }
}

