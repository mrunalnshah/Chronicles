import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chronicles/utilities/data/user_auth_data.dart';
import 'package:chronicles/services/streak_services.dart';
import 'package:chronicles/services/pfp_services.dart';
import 'package:chronicles/services/file_database.dart';
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  late Future<String> _usernameFuture;
  late Future<int> _maxStreakFuture;
  late Future<String?> _pfpPathFuture;
  late Future<bool> _hasWrittenDiaryFuture;
  late Future<int> _diaryCountFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = UserDataFetcher().fetchUsername();
    _maxStreakFuture = StreakDatabaseService.instance.calculateMaxStreak();
    _pfpPathFuture = getSavedImagePath();
    _hasWrittenDiaryFuture = FileDatabase.instance.hasUserWrittenADiary();
    _diaryCountFuture = FileDatabase.instance.getDiaryCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Badges"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black54),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _usernameFuture,
          _maxStreakFuture,
          _pfpPathFuture,
          _hasWrittenDiaryFuture,
          _diaryCountFuture,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final String username = snapshot.data![0];
          final int maxStreak = snapshot.data![1];
          final String? imagePath = snapshot.data![2];
          final bool hasWrittenDiary = snapshot.data![3];
          final int diaryCount = snapshot.data![4];

          List<Map<String, dynamic>> badgeList = [
            {"label": "First Login", "achieved": true},
            {"label": "First Diary", "achieved": hasWrittenDiary},
            {"label": "10 Diaries Made", "achieved": diaryCount >= 10},
            {"label": "30-Day Streak", "achieved": maxStreak >= 30},
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: (imagePath != null &&
                      File(imagePath).existsSync())
                      ? FileImage(File(imagePath))
                      : null,
                  child: (imagePath == null ||
                      !File(imagePath).existsSync())
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "highest streak : $maxStreak",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Achievements",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),


                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: badgeList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final badge = badgeList[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: badge["achieved"]
                            ? const Color(0xFF4EABCC).withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: badge["achieved"]
                              ? Colors.blueAccent
                              : Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            badge["achieved"]
                                ? Icons.emoji_events
                                : Icons.lock_outline,
                            color: badge["achieved"]
                                ? Colors.amber
                                : Colors.grey,
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            badge["label"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: badge["achieved"]
                                  ? Colors.black87
                                  : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
