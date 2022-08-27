import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database? _db;
  DatabaseHelper._instance();

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriorty = 'priorty';
  String colStatus = 'status';

  Future<Database?> get db async {
    _db ??= await _initdb();
    return _db;
  }

  Future<Database> _initdb() async {
    Directory dir = await getApplicationDocumentsDirectory();

    String path = '${dir.path}todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriorty TEXT, $colStatus INTEGER)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(noteTable);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    final List<Map<String, dynamic>> noteMapList = await getNoteMapList();
    final List<Note> noteList = [];
    for (var element in noteMapList) {
      noteList.add(Note.fromMap(element));
    }

    noteList.sort((noteA, noteB) => noteA.date!.compareTo(noteB.date!));

    return noteList;
  }

  Future<int> insertNote(Note note) async {
    Database? db = await this.db;
    final int result = await db!.insert(
      noteTable,
      note.toMap(),
    );

    return result;
  }

  Future<int> updateNote(Note note) async {
    Database? db = await this.db;
    final int result = await db!.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );

    return result;
  }

  Future<int> deleteNote(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(
      noteTable,
      where: '$colId = ?',
      whereArgs: [id],
    );

    return result;
  }
}
