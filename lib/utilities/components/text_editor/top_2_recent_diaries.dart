import 'dart:math';
import 'package:chronicles/services/file_database.dart';
import 'package:flutter/material.dart';
import 'FileData.dart';
import 'chronicles_text_editor.dart';

class Top2RecentDiaries extends StatefulWidget {
  const Top2RecentDiaries({super.key});

  @override
  State<Top2RecentDiaries> createState() => _Top2RecentDiariesState();
}

class _Top2RecentDiariesState extends State<Top2RecentDiaries> {
  List<FileData> fileData = [];
  List<Container> top3Files = [];

  final FileDatabase _fileDB = FileDatabase.instance;

  void _loadFileData() async {
    fileData = await _fileDB.fetchTop3Files();

    setState(() {
      top3Files = fileData.asMap().entries.map((entry) {
        int index = entry.key;
        FileData file = entry.value;

        Color containerColor = _getColorByIndex(index);

        return Container(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TextEditor(
                    fileName: '${file.millisecondSinceEpoch}.json',
                    isModify: true,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(15.0),
              constraints: BoxConstraints(maxWidth: 142.0),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.modifiedAt ?? '',
                    style: TextStyle(
                      fontFamily: "Hind",
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  Text(
                    file.title ?? '',
                    style: TextStyle(
                      fontFamily: "Hind",
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  Text(
                    file.content,
                    style: TextStyle(
                      fontFamily: "Hind",
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList();
    });
  }

  Color _getColorByIndex(int index) {
    List<Color> colors = [
      Color(0xFFD7EFF6),
      Color(0xFFB4E0ED),
      Color(0xFFDAF4FA),
    ];
    return colors[index % colors.length];
  }

  @override
  void initState() {
    super.initState();
    _loadFileData();
  }

  @override
  Widget build(BuildContext context) {
    if (top3Files.isEmpty) {
      return Center(
        child: Text('No Recent Files!!!'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: top3Files,
      ),
    );
  }
}