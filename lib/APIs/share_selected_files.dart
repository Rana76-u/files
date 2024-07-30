import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

void shareFiles(List<String> files) {
  if (files.isNotEmpty) {
    Share.shareFiles(files);
  } else {
    // Optionally show a message if no files are selected
    if (kDebugMode) {
      print('No files selected to share');
    }
  }
}