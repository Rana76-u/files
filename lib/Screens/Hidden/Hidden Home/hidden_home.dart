import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:files/Screens/Hidden/Edit%20Pass/edit_pass.dart';
import 'package:files/Widgets/file_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../../../APIs/file_size_formatter.dart';
import '../../../Bloc/Hidden Home Bloc/hidden_home_bloc.dart';
import '../../../Bloc/Hidden Home Bloc/hidden_home_event.dart';
import '../../../Bloc/Hidden Home Bloc/hidden_home_state.dart';
import 'package:path/path.dart' as path;

import '../../calculator_screens/main/main_screen.dart';

class HiddenHome extends StatelessWidget {
  const HiddenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HiddenHomeBloc(),
      child: const HiddenHomeView(),
    );
  }
}

class HiddenHomeView extends StatefulWidget {
  const HiddenHomeView({super.key,});

  @override
  State<HiddenHomeView> createState() => _HiddenHomeViewState();
}

class _HiddenHomeViewState extends State<HiddenHomeView> {
  @override
  void initState() {
    super.initState();
    context.read<HiddenHomeBloc>().add(LoadFiles());
  }

  TextEditingController folderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HiddenHomeBloc, HiddenHomeState>(
      builder: (context, state) {
        final savedFiles = state.files;

        for(int i=0; i<savedFiles.length; i++){
          if(path.basename(savedFiles[i]) == 'flutter_assets'){
            savedFiles.removeAt(i);
          }
          if(path.basename(savedFiles[i]).contains('res_timestamp')){
            savedFiles.removeAt(i);
          }
        }

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (state.folderPath != '') {
              // Get the parent directory
              String parentFolder = path.dirname(state.folderPath);

              if(path.basename(parentFolder) == 'root' || path.basename(parentFolder) == 'app_flutter'){
                context.read<HiddenHomeBloc>().add(const ChangeFolderPath(''));
              }
              else{
                context.read<HiddenHomeBloc>().add(ChangeFolderPath(parentFolder));
              }
            }

            if(state.checkBoxVisibility){
              context.read<HiddenHomeBloc>().add(ToggleCheckboxVisibility());
              context.read<HiddenHomeBloc>().add(const ToggleSelectAll(false));
            }

          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                state.folderPath != '' ? '/${path.basename(state.folderPath)}' : '/root',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, MainScreen.routeName);
                  },
                  icon: const Icon(Icons.logout_rounded),
                ),

                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                      // Edit folder name
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogBuilderContext) {
                            return SimpleDialog(
                              title: const Text(
                                  'Edit Folder Name'
                              ),
                              contentPadding: const EdgeInsets.all(15),
                              children: [
                                textFieldWidget(folderNameController, 'Input Folder Name'),
                                ElevatedButton(
                                  onPressed: () async {
                                    final navigator = Navigator.pop(dialogBuilderContext);

                                    // Refresh the screen
                                    if (mounted) {
                                      // Dismiss the dialog
                                      navigator;
                                    }

                                    if(folderNameController.text.toLowerCase() != 'root'){
                                      context.read<HiddenHomeBloc>().add(EditFolder(folderNameController.text));
                                    }
                                    else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Folder name cannot be root')),
                                      );
                                    }

                                    folderNameController.clear();
                                  },
                                  child: const Text(
                                      'Submit'
                                  ),
                                )
                              ],
                            );
                          },
                        );
                        break;
                      case 1:
                      // Delete folder
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogueContext) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text("Are you sure you want to delete?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Dismiss the dialog
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final navigator = Navigator.pop(dialogueContext);
                                    /*setState(() {
                                _isLoading = true;
                              });*/
                                    // Dismiss the dialog
                                    if (mounted) {
                                      navigator;
                                    }
                                    // Perform the delete action
                                    context.read<HiddenHomeBloc>().add(DeleteFolder());
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                        break;
                      case 2:
                      // Change password
                        Get.to(
                            () => const EditPass()
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (state.folderPath != '')
                      const PopupMenuItem(
                      value: 0,
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit folder name'),
                      ),
                    ),
                    if (state.folderPath != '')
                    const PopupMenuItem(
                      value: 1,
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red,),
                        title: Text('Delete folder'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change password'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    child: FittedBox(
                      child: FloatingActionButton.extended(
                        heroTag: 'createFolder',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogBuilderContext) {
                              return SimpleDialog(
                                title: const Text(
                                    'CreateFolder'
                                ),
                                contentPadding: const EdgeInsets.all(15),
                                children: [
                                  textFieldWidget(folderNameController, 'Input Folder Name'),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final navigator = Navigator.pop(dialogBuilderContext);

                                      // Refresh the screen
                                      if (mounted) {
                                        // Dismiss the dialog
                                        navigator;
                                      }

                                      if(folderNameController.text.toLowerCase() != 'root'){
                                        context.read<HiddenHomeBloc>().add(CreateFolder(folderNameController.text));
                                      }
                                      else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Folder name cannot be root')),
                                        );
                                      }

                                      folderNameController.clear();
                                    },
                                    child: const Text(
                                        'Submit'
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        label: const Text(
                          'Create Folder',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        icon: const Icon(Icons.folder),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 60,
                    child: FittedBox(
                      child: FloatingActionButton.extended(
                        heroTag: 'addFile',
                        onPressed: () {
                          context.read<HiddenHomeBloc>().add(PickFiles());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        label: const Text(
                          'Add File',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        icon: const Icon(Icons.add_circle_rounded),
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: BlocBuilder<HiddenHomeBloc, HiddenHomeState>(
              builder: (context, state) {
                if(!state.checkBoxVisibility){
                  return const SizedBox();
                }
                return BottomAppBar(
                  height: 75,
                  padding: const EdgeInsets.only(top: 6, left: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: TextButton(
                            onPressed: () {
                              context
                                  .read<HiddenHomeBloc>()
                                  .add(ToggleSelectAll(!state.isSelectAll));
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 25.0,
                                  height: 25.0,
                                  child: Checkbox(
                                    value: state.isSelectAll,
                                    onChanged: (value) {
                                      context
                                          .read<HiddenHomeBloc>()
                                          .add(ToggleSelectAll(value!));
                                    },
                                    materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const Text('Select All')
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: TextButton(
                            onPressed: () {
                              context.read<HiddenHomeBloc>().add(ExportFiles());
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.import_export_rounded),
                                Text('Export')
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: TextButton(
                            onPressed: () {
                              context.read<HiddenHomeBloc>().add(ShareFiles());
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.share_rounded),
                                Text('Share')
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: TextButton(
                            onPressed: () {
                              context.read<HiddenHomeBloc>().add(DeleteFiles());
                              context.read<HiddenHomeBloc>().add(ToggleCheckboxVisibility());
                              context.read<HiddenHomeBloc>().add(const ToggleSelectAll(false));
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.delete),
                                Text('Delete')
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: TextButton(
                            onPressed: () {
                              context
                                  .read<HiddenHomeBloc>()
                                  .add(CancelSelection());
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.cancel),
                                Text('Cancel')
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            body: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
                children: savedFiles.map((path) {
                  final isDirectory = Directory(path).existsSync();

                  if (state.isSelectAll) {
                    context.read<HiddenHomeBloc>().add(SelectFile(path));
                  }

                  return Column(
                    children: [
                      ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: !isDirectory && state.checkBoxVisibility,
                              child: Checkbox(
                                value: state.selectedFiles.contains(path),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                onChanged: (value) {
                                  if (value == true) {
                                    context
                                        .read<HiddenHomeBloc>()
                                        .add(SelectFile(path));
                                  } else {
                                    context
                                        .read<HiddenHomeBloc>()
                                        .add(DeselectFile(path));
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 85,
                              child: isDirectory
                                  ? const Icon(Icons.folder)
                                  : buildFilePreview(PlatformFile(
                                name: File(path).path.split('/').last,
                                path: File(path).path,
                                size: File(path).lengthSync(),
                                bytes: null,
                              )),
                            ),
                          ],
                        ),
                        title: Text(
                          File(path).path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: isDirectory
                            ? const Text('Folder')
                            : Text(
                            formatFileSize(File(path).lengthSync())),
                        onTap: () {
                          if (!isDirectory) {
                            OpenFile.open(File(path).path);
                          }//if it is a folder
                          else{
                            context.read<HiddenHomeBloc>().add(ChangeFolderPath(path));
                          }
                        },
                        onLongPress: () {
                          if (!isDirectory) {
                            context
                                .read<HiddenHomeBloc>()
                                .add(ToggleCheckboxVisibility());
                            context
                                .read<HiddenHomeBloc>()
                                .add(SelectFile(path));
                          }
                        },
                      ),
                      const Divider(
                        height: 5,
                        indent: 110,
                        endIndent: 20,
                        thickness: 1,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget textFieldWidget(TextEditingController textEditingController, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            minHeight: 60,
            maxHeight: 150
        ),
        //height: 60,
        child: TextField(
          controller: textEditingController,
          autofocus: true,
          autocorrect: false,
          maxLines: null,
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            prefixIcon: const Icon(
              Icons.short_text_rounded,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            hintText: hint,
          ),
          cursorColor: Colors.black,
        ),
      ),
    );
  }
}

