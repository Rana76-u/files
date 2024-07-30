String formatFileSize(int bytes) {
  const int kb = 1024;
  const int mb = kb * 1024;

  if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(2)} MB';
  } else if (bytes >= kb) {
    return '${(bytes / kb).toStringAsFixed(2)} KB';
  } else {
    return '$bytes bytes';
  }
}