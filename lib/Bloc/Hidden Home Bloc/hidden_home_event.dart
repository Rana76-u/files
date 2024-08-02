import 'package:equatable/equatable.dart';

abstract class HiddenHomeEvent extends Equatable {
  const HiddenHomeEvent();

  @override
  List<Object> get props => [];
}

class ToggleCheckboxVisibility extends HiddenHomeEvent {}

class ToggleSelectAll extends HiddenHomeEvent {
  final bool value;

  const ToggleSelectAll(this.value);

  @override
  List<Object> get props => [value];
}

class SelectFile extends HiddenHomeEvent {
  final String filePath;

  const SelectFile(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class DeselectFile extends HiddenHomeEvent {
  final String filePath;

  const DeselectFile(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class CreateFolder extends HiddenHomeEvent {
  final String folderName;

  const CreateFolder(this.folderName);

  @override
  List<Object> get props => [folderName];
}

class DeleteFolder extends HiddenHomeEvent {}

class EditFolder extends HiddenHomeEvent {
  final String newFolderName;

  const EditFolder(this.newFolderName);

  @override
  List<Object> get props => [newFolderName];
}

class PickFiles extends HiddenHomeEvent {}

class ExportFiles extends HiddenHomeEvent {}

class ShareFiles extends HiddenHomeEvent {}

class DeleteFiles extends HiddenHomeEvent {}

class CancelSelection extends HiddenHomeEvent {}

class LoadFiles extends HiddenHomeEvent {}

class ChangeFolderPath extends HiddenHomeEvent {
  final String path;

  const ChangeFolderPath(this.path);

  @override
  List<Object> get props => [path];

}