import 'package:flutter/material.dart';
import 'package:streak_calendar/streak_calendar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StreakCalender extends StatefulWidget {
  StreakCalender({super.key});
  late List<DateTime> _activeDates;

  @override
  State<StreakCalender> createState() => _StreakCalenderState();
}

class _StreakCalenderState extends State<StreakCalender> {
  List<DateTime> listStreakDates = [];
  Database? _database;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }


  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'streaks.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE streaks(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT UNIQUE)",
        );
      },
      version: 1,
    );

    await loadStreakDates();
    await didUserLogin();
  }

  Future<void> loadStreakDates() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> results = await _database!.query('streaks');

    setState(() {
      listStreakDates = results
          .map((e) => DateTime.parse(e['date'])) // Convert string to DateTime
          .toList();
    });
  }

  Future<void> didUserLogin() async {
    if (_database == null) return;

    String today = DateTime.now().toIso8601String().split('T')[0];

    List<Map<String, dynamic>> result = await _database!.query(
      'streaks',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (result.isEmpty) {
      await _database!.insert(
        'streaks',
        {'date': today},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      setState(() {
        listStreakDates.add(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CleanCalendar(
      enableDenseViewForDates: true,
      enableDenseSplashForDates: true,
      datesForStreaks: listStreakDates,
      currentDateProperties: DatesProperties(
        datesDecoration: DatesDecoration(
          datesBorderRadius: 1000,
          datesBackgroundColor: Color(0xFFFFFFFF),
          datesBorderColor: Color(0xFFFFFFFF),
          datesTextColor: Color(0xFF1F1F1F),
        ),
      ),
      generalDatesProperties: DatesProperties(
        datesDecoration: DatesDecoration(
          datesBorderRadius: 1000,
          datesBackgroundColor: Color(0xFFFFFFFF),
          datesBorderColor: Color(0xFFFFFFFF),
          datesTextColor: Color(0xFF1F1F1F),
        ),
      ),
      streakDatesProperties: DatesProperties(
        datesDecoration: DatesDecoration(
          datesBorderRadius: 1000,
          datesBackgroundColor: Color(0xFF4EABCC), // Blue streak color
          datesBorderColor: Colors.transparent,
          datesTextColor: Color(0xFFFFFFFF),
        ),
      ),
      leadingTrailingDatesProperties: DatesProperties(
        disable: true,
        hide: true,
        datesDecoration: DatesDecoration(
          datesBorderRadius: 1000,
          datesBackgroundColor: Color(0x104EABCC),
          datesBorderColor: Colors.transparent,
          datesTextColor: Color(0xFF1F1F1F),
        ),
      ),
    );
  }
}