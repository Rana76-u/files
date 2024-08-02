import 'package:equatable/equatable.dart';

class HiddenHomeState extends Equatable {
  final bool checkBoxVisibility;
  final bool isSelectAll;
  final List<String> files;
  final List<String> selectedFiles;
  final String folderPath;

   const HiddenHomeState({
    required this.checkBoxVisibility,
    required this.isSelectAll,
    required this.files,
    required this.selectedFiles,
    required this.folderPath,
  });

  HiddenHomeState copyWith({
    bool? checkBoxVisibility,
    bool? isSelectAll,
    List<String>? files,
    List<String>? selectedFiles,
    String? folderPath,
  }) {
    return HiddenHomeState(
      checkBoxVisibility: checkBoxVisibility ?? this.checkBoxVisibility,
      isSelectAll: isSelectAll ?? this.isSelectAll,
      files: files ?? this.files,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      folderPath: folderPath ?? this.folderPath,
    );
  }

  @override
  List<Object> get props => [checkBoxVisibility, isSelectAll, files, selectedFiles, folderPath];
}
