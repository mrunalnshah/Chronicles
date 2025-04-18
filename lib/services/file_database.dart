/*
* File Name        : file_database.dart
* Group            : trOlsz Group
* Description      : This file has code for all text editor aka
*                    diary related file database operations like Saving a file metadata,
*                    loading a file metadata, deleting a file metadata for
*                    using without reading all file contents. (SQFLITE)
*/

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:chronicles/utilities/components/text_editor/file_data_class.dart';
import '../utilities/data/user_auth_data.dart';

class FileDatabase {
  static Database? _db;
  static final FileDatabase instance = FileDatabase._constructor();

  final String _fileTableName = 'fileList';
  final String _fileIdColumnName = 'id';
  final String _fileEpochValue = 'epochvalue';
  final String _fileTitleColumnName = 'title';
  final String _fileContentColumnName = 'content';
  final String _fileLastModifiedColumnName = 'modified';
  final String _fileCreatedColumnName = 'created';
  final String _fileReactionColumnName = 'reaction';

  FileDatabase._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await getDatabase();
    return _db!;
  }

  static Future<Directory> _getAppDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<Database> getDatabase() async {
    String userId = await UserDataFetcher().fetchUID();
    Directory appDocDir = await _getAppDocumentsDirectory();
    final dbDirPath = await getDatabasesPath();
    final dbPath = '${appDocDir.path}/$userId/$dbDirPath/file_database.db';

    final database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          '''
          CREATE TABLE $_fileTableName (
            $_fileIdColumnName INTEGER PRIMARY KEY,
            $_fileEpochValue INTEGER NOT NULL,
            $_fileTitleColumnName TEXT NOT NULL,
            $_fileContentColumnName TEXT NOT NULL,
            $_fileLastModifiedColumnName TEXT NOT NULL,
            $_fileCreatedColumnName TEXT NOT NULL,
            $_fileReactionColumnName TEXT NOT NULL
          );
          ''',
        );
      },
    );
    return database;
  }

  void saveFileToDatabase({
    required int fileNameInMillisSinceEpoch,
    required String title,
    required String content,
    required String lastModified,
    required String createdAt,
    required String reactionType,
  }) async {
    final db = await database;
    await db.insert(
      _fileTableName,
      {
        _fileEpochValue: fileNameInMillisSinceEpoch,
        _fileTitleColumnName: title,
        _fileContentColumnName: content,
        _fileLastModifiedColumnName: lastModified,
        _fileCreatedColumnName: createdAt,
        _fileReactionColumnName: reactionType,
      },
    );
  }

  Future<List<FileData>> fetchFiles() async {
    final db = await database;
    final data = await db.query(
      _fileTableName,
      orderBy: '$_fileEpochValue ASC',
    );
    List<FileData> fileList = data
        .map(
          (e) => FileData(
        millisecondSinceEpoch: e["epochvalue"] as int,
        title: e["title"] as String,
        content: e["content"] as String,
        modifiedAt: e["modified"] as String,
        createdAt: e["created"] as String,
        reactionType: e["reaction"] as String,
      ),
    )
        .toList();
    return fileList;
  }

  Future<List<FileData>> fetchFilesByDate(String date) async {
    final db = await database;
    final data = await db.query(
      _fileTableName,
      where: '$_fileCreatedColumnName = ?',
      whereArgs: [date],
      orderBy: '$_fileEpochValue ASC',
    );

    List<FileData> fileList = data
        .map(
          (e) => FileData(
        millisecondSinceEpoch: e["epochvalue"] as int,
        title: e["title"] as String,
        content: e["content"] as String,
        modifiedAt: e["modified"] as String,
        createdAt: e["created"] as String,
        reactionType: e["reaction"] as String,
      ),
    )
        .toList();

    return fileList;
  }

  Future<List<FileData>> fetchTop3Files() async {
    final db = await database;
    final data = await db.query(
      _fileTableName,
      orderBy: '$_fileEpochValue DESC',
      limit: 3,
    );

    List<FileData> fileList = data
        .map(
          (e) => FileData(
        millisecondSinceEpoch: e["epochvalue"] as int,
        title: e["title"] as String,
        content: e["content"] as String,
        modifiedAt: e["modified"] as String,
        createdAt: e["created"] as String,
        reactionType: e["reaction"] as String,
      ),
    )
        .toList();

    return fileList;
  }

  Future<void> updateFile({
    required int id,
    required String content,
    required String title,
    required String modifiedAt,
    required String reactionType,
  }) async {
    final db = await database;
    await db.update(
      _fileTableName,
      {
        _fileTitleColumnName: title,
        _fileContentColumnName: content,
        _fileLastModifiedColumnName: modifiedAt,
        _fileReactionColumnName: reactionType,
      },
      where: '$_fileEpochValue = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFile(int id) async {
    final db = await database;
    await db.delete(
      _fileTableName,
      where: '$_fileEpochValue = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasUserWrittenADiary() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_fileTableName'),
    );
    return (count ?? 0) > 0;
  }

  Future<int> getDiaryCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_fileTableName'),
    );
    return count ?? 0;
  }
}
