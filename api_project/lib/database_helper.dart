import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'student_model.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentname TEXT,
        fathername TEXT,
        progname TEXT,
        shift TEXT,
        rollno TEXT,
        coursecode TEXT,
        coursetitle TEXT,
        credithours TEXT,
        obtainedmarks TEXT,
        mysemester TEXT,
        consider_status TEXT
      )
    ''');
  }

  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<void> deleteAllStudents() async {
    final db = await database;
    await db.delete('students');
  }
  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
}
}
