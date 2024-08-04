import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

buildFilePreview(PlatformFile file) {
  if (file.extension == 'jpg' || file.extension == 'jpeg' || file.extension == 'png') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(file.path!),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }
  else if (file.extension == 'txt') {
    return const Icon(Icons.text_snippet_rounded, color: Colors.grey);
  } else if (file.extension == 'mp4' || file.extension == 'avi' || file.extension == 'mov') {
    return const Icon(Icons.play_circle_fill_rounded, color: Colors.green);
  } else if (file.extension == 'pdf') {
    return const Icon(Icons.picture_as_pdf_rounded, color: Colors.red);
  }
  else {
  return const Icon(Icons.insert_drive_file, color: Colors.blue);
  }
}
