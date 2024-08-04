import 'package:hive/hive.dart';

final Box<String> myBox = Hive.box<String>('userDetails');

String password = '';

void addToHive(String key, String value) {
  myBox.put(key, value);
}

String? getFromHive(String key) {
  return myBox.get(key);
}

void updateHive(String key, String value) {
  myBox.put(key, value);
}

void deleteFromHive(String key) {
  myBox.delete(key);
}