import 'package:flutter_bloc/flutter_bloc.dart';
import '../../APIs/file_api.dart';
import '../../APIs/folder_api.dart';
import '../../APIs/share_selected_files.dart';
import 'hidden_home_event.dart';
import 'hidden_home_state.dart';
import 'package:path/path.dart' as path;

class HiddenHomeBloc extends Bloc<HiddenHomeEvent, HiddenHomeState> {
  HiddenHomeBloc()
      : super(const HiddenHomeState(
    isLoading: true,
    checkBoxVisibility: false,
    isSelectAll: false,
    files: [],
    selectedFiles: [],
    folderPath: ''
  )) {
    on<IsLoading>(_onIsLoading);
    on<ToggleCheckboxVisibility>(_onToggleCheckboxVisibility);
    on<ToggleSelectAll>(_onToggleSelectAll);
    on<SelectFile>(_onSelectFile);
    on<DeselectFile>(_onDeselectFile);
    on<CreateFolder>(_onCreateFolder);
    on<PickFiles>(_onPickFiles);
    on<ExportFiles>(_onExportFiles);
    on<ShareFiles>(_onShareFiles);
    on<DeleteFiles>(_onDeleteFiles);
    on<CancelSelection>(_onCancelSelection);
    on<LoadFiles>(_loadFiles);
    on<ChangeFolderPath>(_changeFolderPath);
    on<DeleteFolder>(_deleteFolder);
    on<EditFolder>(_editFolder);
  }

  void _onIsLoading(IsLoading event, Emitter<HiddenHomeState> emit) async {
    emit(state.copyWith(isLoading: event.isLoading));
  }

  Future<void> _loadFiles(LoadFiles event, Emitter<HiddenHomeState> emit) async {
    final files = await getSavedFilesAndFolders('');
    emit(state.copyWith(
        isLoading: false,
        files: files));
  }

  void _changeFolderPath(ChangeFolderPath event, Emitter<HiddenHomeState> emit) async {
    final files = await getSavedFilesAndFolders(event.path);
    emit(state.copyWith(
        isLoading: false,
        folderPath: event.path,
        files: files));
  }

  void _deleteFolder(DeleteFolder event, Emitter<HiddenHomeState> emit) async {

    String newFolderPath = path.dirname(state.folderPath);
    await deleteFolder(state.folderPath);
    final files = await getSavedFilesAndFolders(newFolderPath);

    emit(state.copyWith(isLoading: false, folderPath: newFolderPath,  files: files));
  }

  void _editFolder(EditFolder event, Emitter<HiddenHomeState> emit) async {

    String newFolderPath = '${path.dirname(state.folderPath)}/${event.newFolderName}';

    await editFolder(event.newFolderName, state.folderPath);

    final files = await getSavedFilesAndFolders(newFolderPath);

    emit(state.copyWith(isLoading: false, folderPath: newFolderPath,  files: files));
  }

  void _onPickFiles(PickFiles event, Emitter<HiddenHomeState> emit) async {
    await pickFiles(state.folderPath);
    emit(state.copyWith(isLoading: false, files:await getSavedFilesAndFolders(state.folderPath)));
  }

  void _onExportFiles(ExportFiles event, Emitter<HiddenHomeState> emit) async {
    for (final file in state.selectedFiles) {
      await exportFileToDownloads(file.split('/').last);
    }
  }

  void _onDeleteFiles(DeleteFiles event, Emitter<HiddenHomeState> emit) async {
    for (final filePath in state.selectedFiles) {
      await deleteFileByPath(filePath); //file.split('/').last
    }
    emit(state.copyWith(
        isLoading: false,
        selectedFiles: [],
        files: await getSavedFilesAndFolders(state.folderPath))
    );
  }

  void _onToggleCheckboxVisibility(
      ToggleCheckboxVisibility event, Emitter<HiddenHomeState> emit) {
    emit(state.copyWith(checkBoxVisibility: !state.checkBoxVisibility));
  }

  void _onToggleSelectAll(ToggleSelectAll event, Emitter<HiddenHomeState> emit) {
    emit(state.copyWith(isSelectAll: event.value, selectedFiles: event.value ? List.from(state.selectedFiles) : []));
  }

  void _onSelectFile(SelectFile event, Emitter<HiddenHomeState> emit) {
    final updatedSelectedFiles = List<String>.from(state.selectedFiles)..add(event.filePath);
    emit(state.copyWith(selectedFiles: updatedSelectedFiles));
  }

  void _onDeselectFile(DeselectFile event, Emitter<HiddenHomeState> emit) {
    final updatedSelectedFiles = List<String>.from(state.selectedFiles)..remove(event.filePath);
    emit(state.copyWith(selectedFiles: updatedSelectedFiles));
  }

  void _onCreateFolder(CreateFolder event, Emitter<HiddenHomeState> emit) async {
    await createFolder(event.folderName, state.folderPath);
    emit(state.copyWith(files: await getSavedFilesAndFolders(state.folderPath)));
  }

  void _onShareFiles(ShareFiles event, Emitter<HiddenHomeState> emit) {
    shareFiles(state.selectedFiles);
  }

  void _onCancelSelection(CancelSelection event, Emitter<HiddenHomeState> emit) {
    emit(state.copyWith(checkBoxVisibility: false, isSelectAll: false, selectedFiles: []));
  }

}
