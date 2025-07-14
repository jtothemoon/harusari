import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../models/todo.dart';
import '../utils/date_utils.dart' as date_utils;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getDatabasesPath();
    final path = join(directory, 'harutodo.db');

    return await openDatabase(
      path,
      version: 1, // 버전 1로 되돌림 (깔끔하게 시작)
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        priority INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');

    // 성능 향상을 위한 인덱스 추가
    await db.execute('CREATE INDEX idx_todos_created_at ON todos(createdAt)');
    await db.execute(
      'CREATE INDEX idx_todos_completed_at ON todos(completedAt)',
    );
    await db.execute('CREATE INDEX idx_todos_priority ON todos(priority)');
    await db.execute(
      'CREATE INDEX idx_todos_is_completed ON todos(isCompleted)',
    );

    // 설정 테이블 추가
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // 할 일 추가
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  // 모든 할 일 조회 (오늘 날짜 기준)
  Future<List<Todo>> getTodosForToday() async {
    final db = await database;
    final (startOfDay, endOfDay) = date_utils.DateUtils.getTodayRange();

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'priority ASC, createdAt ASC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // 완료되지 않은 할 일만 조회
  Future<List<Todo>> getIncompleteTodosForToday() async {
    final db = await database;
    final (startOfDay, endOfDay) = date_utils.DateUtils.getTodayRange();

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'createdAt >= ? AND createdAt < ? AND isCompleted = 0',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'priority ASC, createdAt ASC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // 완료된 할 일 조회 (특정 날짜)
  Future<List<Todo>> getCompletedTodosForDate(DateTime date) async {
    final db = await database;
    final (startOfDay, endOfDay) = date_utils.DateUtils.getDayRange(date);

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'completedAt >= ? AND completedAt < ? AND isCompleted = 1',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'completedAt DESC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // 특정 ID로 할 일 조회
  Future<Todo?> getTodoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  // 할 일 업데이트
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // 할 일 삭제
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // 오늘 완료된 할 일 개수 조회
  Future<Map<Priority, int>> getCompletedCountForToday() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'completedAt >= ? AND completedAt < ? AND isCompleted = 1',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    Map<Priority, int> counts = {
      Priority.high: 0,
      Priority.medium: 0,
      Priority.low: 0,
    };

    for (var map in maps) {
      final priority = Priority.values[map['priority']];
      counts[priority] = (counts[priority] ?? 0) + 1;
    }

    return counts;
  }

  // 오늘 생성된 할 일 개수 조회
  Future<Map<Priority, int>> getCreatedCountForToday() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'todos',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    final counts = {Priority.high: 0, Priority.medium: 0, Priority.low: 0};
    for (final row in result) {
      final priority = Priority.values[row['priority'] as int];
      counts[priority] = counts[priority]! + 1;
    }

    return counts;
  }

  // 설정값 저장
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 설정값 조회
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  // 설정값 삭제
  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  // 하루 시작 시간 저장
  Future<void> saveDayStartTime(TimeOfDay time) async {
    await saveSetting('day_start_hour', time.hour.toString());
    await saveSetting('day_start_minute', time.minute.toString());
  }

  // 하루 시작 시간 조회
  Future<TimeOfDay> getDayStartTime() async {
    final hourStr = await getSetting('day_start_hour');
    final minuteStr = await getSetting('day_start_minute');

    if (hourStr != null && minuteStr != null) {
      final hour = int.tryParse(hourStr) ?? 6;
      final minute = int.tryParse(minuteStr) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }

    // 기본값
    return const TimeOfDay(hour: 6, minute: 0);
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
