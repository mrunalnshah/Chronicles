import 'package:chronicles/utilities/components/calender/streak_calender.dart';
import 'package:chronicles/utilities/components/todo/todo_main.dart';
import 'package:chronicles/utilities/image_import/logo_import.dart';
import 'package:flutter/material.dart';

import 'package:chronicles/utilities/components/searchbar/boxSearchBar.dart';
import 'package:chronicles/utilities/components/text_editor/chronicles_text_editor.dart';

import '../../utilities/components/todo/todo_top_three.dart';

final String username = "trOlsz";

final helloMsgStyle = TextStyle(
  height: 1.8,
  fontSize: 32.0,
  fontFamily: 'Klee_One',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

final usernameStyle = TextStyle(
  height: 1.8,
  fontSize: 32.0,
  fontFamily: 'Klee_One',
  fontWeight: FontWeight.w500,
  color: Color(0xFF4EABCC),
);

final hintTextStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w400,
  color: Color(0xFF1F1F1F),
);

final headingTextStyle = TextStyle(
  fontSize: 24.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

final taskListTextStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

final taskTitleTextField = TextStyle(
  fontSize: 24.0,
  fontFamily: 'Hind',
  color: Color(0xFF1F1F1F),
);

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF4EABCC),
        shape: CircleBorder(),
        child: Icon(Icons.edit_outlined, color: Color(0xFFFFFFFF)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TextEditor(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFD7EFF6),
        height: 62.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        scrolledUnderElevation: 0.5,
        title: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Hello,",
                    style: helloMsgStyle,
                  ),
                  Text(username, style: usernameStyle),
                ],
              ),
              ImageImport(width: 56, height: 56).importProfileIcon(),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 5, bottom: 20, left: 15, right: 15),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0, left: 5, right: 5),
                child: BoxSearchBar(),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                padding: EdgeInsets.only(top: 30.0, bottom: 20.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    border: Border.all(
                      color: Color(0x40000000),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: StreakCalender(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task',
                    style: taskTitleTextField,
                  ),
                  IconButton(
                    constraints: BoxConstraints(maxHeight: 36),
                    color: Color(0xFFFFFFFF),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ToDoList(),
                        ),
                      );
                    },
                    icon: Icon(Icons.add_rounded, size: 24.0),
                    style: IconButton.styleFrom(
                      backgroundColor: Color(0xFF4EABCC),
                      padding: EdgeInsets.all(0.0),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                padding: EdgeInsets.fromLTRB(10.0,20.0,20.0,10.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  border: Border.all(
                    color: Color(0x40000000),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Top3ToDoList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
