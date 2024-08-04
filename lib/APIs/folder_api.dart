import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> createFolder(String folderName, String directoryPath) async {
  final directory = await getApplicationDocumentsDirectory();
  String folderPath = '';
  if(directoryPath == ''){
    if(folderName == ''){
      folderPath = '${directory.path}/root';
    }
    else{
      folderPath = '${directory.path}/root/$folderName';
    }
  }
  else{
    folderPath = '$directoryPath/$folderName';
  }

  final folder = Directory(folderPath);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
    await saveFolderPath(folderPath);
  }
}

Future<void> saveFolderPath(String path) async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final allKeys = await secureStorage.readAll();
  final folderIndex = allKeys.length;
  await secureStorage.write(key: 'folder_$folderIndex', value: path);
}


Future<void> deleteFolder(String directoryPath) async {
  //final directory = await getApplicationDocumentsDirectory();
  String folderPath = directoryPath; //folderPath

  final folder = Directory(folderPath);
  if (await folder.exists()) {
    await folder.delete(recursive: true);
    await removeFolderPath(folderPath);
  }
}

Future<void> removeFolderPath(String path) async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final allKeys = await secureStorage.readAll();
  for (String key in allKeys.keys) {
    final storedPath = await secureStorage.read(key: key);
    if (storedPath == path) {
      await secureStorage.delete(key: key);
      break;
    }
  }
}


Future<void> editFolder(String newFolderName, String folderPath) async {

  String oldFolderPath = '';
  String newFolderPath = '';

  oldFolderPath = folderPath;
  newFolderPath = '${path.dirname(folderPath)}/$newFolderName';

  final oldFolder = Directory(oldFolderPath);
  final newFolder = Directory(newFolderPath);

  if (await oldFolder.exists() && !await newFolder.exists()) {
    await oldFolder.rename(newFolderPath);
    await updateFolderPath(oldFolderPath, newFolderPath);
  }
}

Future<void> updateFolderPath(String oldPath, String newPath) async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final allKeys = await secureStorage.readAll();
  for (String key in allKeys.keys) {
    final storedPath = await secureStorage.read(key: key);
    if (storedPath == oldPath) {
      await secureStorage.write(key: key, value: newPath);
      break;
    }
  }
}