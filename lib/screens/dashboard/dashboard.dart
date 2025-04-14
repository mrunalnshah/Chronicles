/*
* File Name        : dashboard.dart
* Group            : trOlsz Group
* Description      : This file has code for the Dashboard Screen
*
* NOTE: Fetching Username should be from secureData.
*/

// Importing Packages
import 'package:chronicles/screens/todo/recent_todo.dart';
import 'package:chronicles/utilities/data/user_auth_data.dart';
import 'package:flutter/material.dart';
import 'package:chronicles/screens/todo/todo_screen.dart';
import 'package:chronicles/utilities/components/searchbar/box_search_bar.dart';
import 'package:chronicles/utilities/components/text_editor/recent_diaries.dart';
import 'package:chronicles/screens/profile/profile_screen.dart';
import 'package:chronicles/utilities/components/floating_action_button/dashboard_fab.dart';
import 'dart:io';
import 'package:chronicles/services/pfp_services.dart';
import 'package:chronicles/utilities/components/profile/profile_avatar.dart';
import 'package:lottie/lottie.dart';

import '../../services/streak_services.dart';
import '../../utilities/components/calender/calendar.dart';

// Variable Values and TextStyles
final double scrolledUnderElevationValue = 0.5;
final double circleAvatarRadius = 24.0;
final double appBarTopPadding = 8.0;
final double bodyTopPadding = 5.0;
final double bodyBottomPadding = 20.0;
final double bodyLeftPadding = 15.0;
final double bodyRightPadding = 15.0;
final double searchBarTopPadding = 20.0;
final double searchBarLeftPadding = 5.0;
final double searchBarRightPadding = 5.0;
final double streakHorizontalMargin = 6.0;
final double streakTopPadding = 30.0;
final double streakBottomPaddin = 20.0;
final double streakInsidePaddingAll = 10.0;
final double streakBorderWidth = 2.0;
final double streakBorderRadius = 6.0;
final double todoIconButtonMaxHeight = 36.0;
final double todoIconSize = 24.0;
final double todoIconPadding = 0.0;
final double recentTodoHorizontalMargin = 6.0;
final double recentTodoLeftPadding = 10.0;
final double recentTodoTopPadding = 10.0;
final double recentTodoRightPadding = 20.0;
final double recentTodoBottomPadding = 10.0;
final double recentTodoBorderWidth = 2.0;
final double recentTodoBorderRadius = 6.0;
final double recentTodoMaxHeight = 200.0;
final double sizedBoxBetweenTodoAndRecent = 20.0;
final double recentDiariesHorizontalMargin = 6.0;
final double recentDiariesLeftPadding = 10.0;
final double recentDiariesTopPadding = 20.0;
final double recentDiariesRightPadding = 20.0;
final double recentDiariesBottomPadding = 10.0;
final double recentDiaryBorderWidth = 2.0;
final double recentDiaryBorderRadius = 6.0;
final double recentDiaryContainerHeight = 190.0;

final Color appBarBGColor = Color(0xFFFFFFFF);
final Color streakContainerColor = Color(0xFFFFFFFF);
final Color streakBorderColor = Color(0x40000000);
final Color todoIconColor = Color(0xFFFFFFFF);
final Color todoIconBGColor = Color(0xFF4EABCC);
final Color recentTodoBGColor = Color(0xFFFFFFFF);
final Color recentTodoBorderColor = Color(0x40000000);
final Color diaryArchiveIconColor = Color(0xFF4EABCC);
final Color recentDiaryBGColor = Color(0xFFFFFFFF);
final Color recentDiaryBorderColor = Color(0x40000000);

final String appBarMessage = "Hello,";
final String taskTextString = "Task";
final String recentTextString = "Recent";
String username = "Loading...";
File? profileImage;

final helloMsgStyle = TextStyle(
  height: 1.8,
  fontSize: 28.0,
  fontFamily: 'Abyssinica_SIL',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

final usernameStyle = TextStyle(
  height: 1.8,
  fontSize: 28.0,
  fontFamily: 'Abyssinica_SIL',
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
  fontWeight: FontWeight.w500,
  fontFamily: 'Hind',
  color: Color(0xFF1F1F1F),
);

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentStreak = 0;
  int maxStreak = 0;

  @override
  void initState() {
    fetchUserDetail();
    super.initState();
  }

  void fetchUserDetail() async {
    String uname = await UserDataFetcher().fetchUsername();

    uname = uname[0].toUpperCase() + uname.substring(1);
    String? imagePath = await getSavedImagePath();
    setState(() {
      username = uname;
      if (imagePath != null) {
        profileImage = File(imagePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: DashboardFab(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      appBar: AppBar(
        backgroundColor: appBarBGColor,
        scrolledUnderElevation: scrolledUnderElevationValue,
        title: Padding(
          padding: EdgeInsets.only(top: appBarTopPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    appBarMessage,
                    style: helloMsgStyle,
                  ),
                  Text(
                    username,
                    style: usernameStyle,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                child: ProfileAvatar(
                  circleAvatarRadius: 24,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: bodyTopPadding,
            bottom: bodyBottomPadding,
            left: bodyLeftPadding,
            right: bodyRightPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: searchBarTopPadding,
                  left: searchBarLeftPadding,
                  right: searchBarRightPadding,
                ),
                child: BoxSearchBar(),
              ),
              Container(
                margin:
                    EdgeInsets.symmetric(horizontal: streakHorizontalMargin),
                padding: EdgeInsets.only(
                  top: streakTopPadding,
                  bottom: streakBottomPaddin,
                ),
                child: Container(
                  padding: EdgeInsets.all(streakInsidePaddingAll),
                  decoration: BoxDecoration(
                    color: streakContainerColor,
                    border: Border.all(
                      color: streakBorderColor,
                      width: streakBorderWidth,
                    ),
                    borderRadius: BorderRadius.circular(streakBorderRadius),
                  ),
                  child: Calendar(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    taskTextString,
                    style: taskTitleTextField,
                  ),
                  IconButton(
                    constraints:
                        BoxConstraints(maxHeight: todoIconButtonMaxHeight),
                    color: todoIconColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ToDoScreen(),
                        ),
                      );
                      setState(() {});
                    },
                    icon: Icon(Icons.add_rounded, size: todoIconSize),
                    style: IconButton.styleFrom(
                      backgroundColor: todoIconBGColor,
                      padding: EdgeInsets.all(todoIconPadding),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: recentTodoHorizontalMargin),
                padding: EdgeInsets.only(
                  left: recentTodoLeftPadding,
                  top: recentTodoTopPadding,
                  right: recentTodoRightPadding,
                  bottom: recentTodoBottomPadding,
                ),
                decoration: BoxDecoration(
                  color: recentTodoBGColor,
                  border: Border.all(
                    color: recentTodoBorderColor,
                    width: recentTodoBorderWidth,
                  ),
                  borderRadius: BorderRadius.circular(recentTodoBorderRadius),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: recentTodoMaxHeight),
                  child: RecentToDo(),
                ),
              ),
              SizedBox(
                height: sizedBoxBetweenTodoAndRecent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      recentTextString,
                      style: taskTitleTextField,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/DiaryArchive');
                    },
                    icon: Icon(
                      Icons.more_horiz_sharp,
                      color: diaryArchiveIconColor,
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: recentDiariesHorizontalMargin,
                ),
                padding: EdgeInsets.only(
                  left: recentDiariesLeftPadding,
                  top: recentDiariesTopPadding,
                  right: recentDiariesRightPadding,
                  bottom: recentDiariesBottomPadding,
                ),
                decoration: BoxDecoration(
                  color: recentDiaryBGColor,
                  border: Border.all(
                    color: recentDiaryBorderColor,
                    width: recentDiaryBorderWidth,
                  ),
                  borderRadius: BorderRadius.circular(recentDiaryBorderRadius),
                ),
                child: Top2RecentDiaries(),
              ),
              SizedBox(
                height: 100.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
