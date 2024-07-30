import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../../../APIs/file_api.dart';
import '../../../APIs/file_size_formatter.dart';
import '../../../APIs/share_selected_files.dart';
import '../../../Widgets/file_preview.dart';

class HiddenHome extends StatefulWidget {
  const HiddenHome({super.key});

  @override
  State<HiddenHome> createState() => _HiddenHomeState();
}

class _HiddenHomeState extends State<HiddenHome> {

  bool checkBoxVisibility = false;
  bool isSelectAll = false;
  List<String> selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
          title: const Text(
              'Files',
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
      ),
      floatingActionButton: SizedBox(
        height: 60,
        width: 200,
        child: FittedBox(
          child: FloatingActionButton.extended(
            onPressed: () async {
              await pickFiles();
              setState(() {});
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            label: const Text(
              'Add File',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
            icon: const Icon(
                Icons.add_circle_rounded
            ),
          ),
        ),
      ),
      bottomNavigationBar: checkBoxVisibility
          ? BottomAppBar(
        height: 75,
        padding: const EdgeInsets.only(top: 6, left: 20,),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: TextButton(
                  onPressed: () {},
                  child: Column(
                    children: [
                      SizedBox(
                        width: 25.0,
                        height: 25.0,
                        child: Checkbox(
                          value: isSelectAll,
                          onChanged: (value) {
                            setState(() {
                              isSelectAll = value!;
                              if (!isSelectAll) {
                                selectedFiles.clear();
                              }
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  onPressed: () async {
                    for(int i=0; i<selectedFiles.length; i++){
                      await exportFileToDownloads(selectedFiles[i].split('/').last);
                    }
                    setState(() {});
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
                    shareFiles(selectedFiles);
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
                  onPressed: () async {
                    for(int i=0; i<selectedFiles.length; i++){
                      await deleteFile(selectedFiles[i].split('/').last);
                    }
                    setState(() {});
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
                    setState(() {
                      checkBoxVisibility = false;
                      isSelectAll = false;
                      selectedFiles.clear();
                    });
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
      )
          : null,
      body: SingleChildScrollView(
        child: FutureBuilder<List<String>>(
          future: getSavedFiles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            else if (snapshot.hasError) {
              return const Text('Error loading saved files');
            }
            else {
              final savedFiles = snapshot.data ?? [];
              return Column(
                children: savedFiles.map((path) {
                  final file = File(path);

                  if(isSelectAll){
                    selectedFiles.add(path);
                  }

                  return Column(
                    children: [
                      ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: checkBoxVisibility,
                              child: Checkbox(
                                value: selectedFiles.contains(path),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if(selectedFiles.contains(path)){
                                      selectedFiles.remove(path);
                                    }
                                    else{
                                      selectedFiles.add(path);
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 85,
                              child: buildFilePreview(PlatformFile(
                                name: file.path.split('/').last,
                                path: file.path,
                                size: file.lengthSync(),
                                bytes: null,
                              )),
                            )
                          ],
                        ),
                        title: Text(
                          file.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(formatFileSize(file.lengthSync())),
                        onTap: () => OpenFile.open(file.path),
                        /*onLongPress: () async {
                          await deleteFile(file.path.split('/').last);
                          setState(() {
                          });
                        },*/
                        onLongPress: () {
                          setState(() {
                            checkBoxVisibility = true;
                            selectedFiles.add(path);
                          });
                        },
                      ),
                      const Divider(
                        height: 5,
                        indent: 110,
                        endIndent: 20,
                        thickness: 1,
                      )
                    ],
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }
}
