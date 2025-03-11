import 'package:chronicles/services/file_database.dart';
import 'package:chronicles/utilities/components/text_editor/editor_textbox.dart';
import 'package:flutter/material.dart';
import 'package:chronicles/utilities/components/date_time/current_datetime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chronicles/services/file_manager.dart';

final titleTextStyle = TextStyle(
  color: Color(0xFF1F1F1F),
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  fontSize: 22.0,
);

class TextEditor extends StatefulWidget {
  String? fileName;
  int? milliSinceEpoch;
  bool? isModify;

  TextEditor({super.key, this.fileName, this.isModify});

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  List<TextEditingController> controllers = [];
  List<bool> editModes = [];
  TextEditingController titleController = TextEditingController();

  final FileDatabase _fileDB = FileDatabase.instance;

  String createdAt = '';
  String modifiedAt = '';
  late CurrentDateTime nowTime;

  @override
  void initState() {
    nowTime = CurrentDateTime();
    if (widget.fileName == null) {
      controllers.add(TextEditingController());
      editModes.add(true);

      String weekday = nowTime.getCurrentWeekDay();
      int day = nowTime.getCurrentDay();
      String month = nowTime.getCurrentMonth();
      int year = nowTime.getCurrentYear();

      createdAt = '$weekday, $day-$month-$year';
      modifiedAt = '$weekday, $day-$month-$year';

      widget.fileName = '${nowTime.getMilliSecondSinceEpoch()}.json';
    } else {
      String? milliSinceEpochString = widget.fileName?.split('.').first;
      int milliSinceEpoch = int.parse(milliSinceEpochString!);
      nowTime.convertMilliSecondsSinceEpochToDateTime(milliSinceEpoch);

      _loadFile(widget.fileName!);
    }
    super.initState();
  }

  void _saveFileToDB(
      {required int milliSinceEpoch,
      required String title,
      required String content,
      required String lastModified,
      required String createdAt}) {
    _fileDB.saveFileToDatabase(
        fileNameInMillisSinceEpoch: milliSinceEpoch,
        title: title,
        content: content,
        lastModified: lastModified,
        createdAt: createdAt);
  }

  void _updateFileToDB({
    required int milliSinceEpoch,
    required String title,
    required String content,
    required String lastModified,
  }) {
    _fileDB.updateFile(
      id: milliSinceEpoch,
      title: title,
      content: content,
      modifiedAt: lastModified,
    );
  }

  void _deleteFileToDB({required int milliSinceEpoch}) {
    _fileDB.deleteFile(milliSinceEpoch);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TextEditingController controller = controllers.removeAt(oldIndex);
      final bool editMode = editModes.removeAt(oldIndex);
      controllers.insert(newIndex, controller);
      editModes.insert(newIndex, editMode);
    });
  }

  void _insertController() {
    setState(() {
      controllers.add(TextEditingController());
      editModes.add(true);
    });
  }

  void _insertImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    int imageMilliSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    String imagePath = await FileManager.saveImageFile(
      filename: widget.fileName!,
      image: image!,
      imageName: '$imageMilliSinceEpoch.${image.name.split('.').last}',
    );
    setState(() {
      controllers.add(
        TextEditingController(
            text: '![Type Image Description Here]($imagePath)'),
      );
      editModes.add(false);
    });
  }

  void _deleteController(int index) {
    setState(() {
      controllers.removeAt(index);
      editModes.removeAt(index);
    });
  }

  void _toggleEditMode(int index) {
    setState(() {
      editModes[index] = !editModes[index];

      if (index > 0) {
        _removeController();
      }
    });
  }

  void _removeController() {
    setState(() {
      for (int i = 0; i < controllers.length; i++) {
        if (controllers[i].text.isEmpty) {
          _deleteController(i);
        }
      }
    });
  }

  void _saveFile() {
    setState(() {
      if (widget.isModify == false) {
        String fileName = '${nowTime.getMilliSecondSinceEpoch()}.json';

        _saveFileToDB(
          milliSinceEpoch: nowTime.getMilliSecondSinceEpoch(),
          title: titleController.text,
          content: controllers[0].text.length >= 25
              ? controllers[0].text.substring(0, 25)
              : controllers[0].text,
          lastModified: modifiedAt,
          createdAt: createdAt,
        );
        FileManager.saveFileAsJson(
          title: titleController.text,
          createDate: createdAt,
          modifyDate: modifiedAt,
          controller: controllers,
          milliSinceEpoch: nowTime.getMilliSecondSinceEpoch(),
        );
      } else if (widget.fileName != null && widget.isModify == true) {
        int milliSinceEpoch =
            int.parse(widget.fileName!.replaceAll('.json', ''));
        _updateFileToDB(
          milliSinceEpoch: milliSinceEpoch,
          title: titleController.text,
          content: controllers[0].text.length >= 25
              ? controllers[0].text.substring(0, 25)
              : controllers[0].text,
          lastModified: modifiedAt,
        );

        FileManager.modifyJsonFile(
          fileName: widget.fileName!,
          title: titleController.text,
          createDate: createdAt,
          modifyDate: modifiedAt,
          controller: controllers,
        );
      }
    });
  }

  void _loadFile(String fileName) {
    setState(() {
      FileManager.loadJsonFile(fileName).then((fileData) {
        if (fileData != null) {
          setState(() {
            titleController.text = fileData['title'];
            createdAt = fileData['createdAt'];
            modifiedAt = fileData['modifiedAt'];
            controllers = List.generate(
              fileData['controllers'].length,
              (index) => TextEditingController(
                text: fileData['controllers'][index],
              ),
            );
            editModes = List.generate(controllers.length, (index) => false);
          });
        }
      });
    });
  }

  void _deleteFile() {
    setState(() {
      int milliSinceEpoch = int.parse(widget.fileName!.split('.').first);
      _deleteFileToDB(milliSinceEpoch: milliSinceEpoch);
      FileManager.deleteJsonFile(fileName: widget.fileName!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(createdAt),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _saveFile();
                    });
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/Dashboard',
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: Icon(Icons.save_alt),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _deleteFile();
                    });
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/Dashboard',
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: Icon(Icons.delete_outline_sharp),
                ),
                // IconButton(
                //   onPressed: () {},
                //   icon: Icon(Icons.upload, color: Colors.white, size: 2.0,),
                //   style:
                //       IconButton.styleFrom(backgroundColor: Color(0xFF4EABCC)),
                // ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/Dashboard',
              (Route<dynamic> route) => false,
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: TextField(
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Hind',
                  fontWeight: FontWeight.w600,
                  fontSize: 22.0,
                ),
                controller: titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title',
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controllers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  minVerticalPadding: 0.0,
                  key: ValueKey(controllers[index]),
                  leading: Icon(
                    Icons.drag_indicator,
                    color: Color(0xFF4EABCC),
                  ),
                  title: EditorTextBox(
                    controller: controllers[index],
                    editMode: editModes[index],
                    onToggleEdit: () => _toggleEditMode(index),
                    onDelete: () => _deleteController(index),
                  ),
                );
              },
              onReorder: _onReorder,
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 18.0),
              margin: EdgeInsets.only(bottom: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Color(0x104EABCC),
                    child: MaterialButton(
                      onPressed: _insertController,
                      child: Icon(
                        Icons.text_fields,
                        color: Color(0xFF4EABCC),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    color: Color(0x104EABCC),
                    child: MaterialButton(
                      onPressed: _insertImage,
                      child: Icon(
                        Icons.image,
                        color: Color(0xFF4EABCC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
