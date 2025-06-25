import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';
import 'package:flutter/material.dart';

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
      version: 2, // 버전 업데이트
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
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
    
    // 설정 테이블 추가
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 설정 테이블 추가
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings(
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  // 할 일 추가
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  // 모든 할 일 조회 (오늘 날짜 기준)
  Future<List<Todo>> getTodosForToday() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'CAST(createdAt AS INTEGER) >= ? AND CAST(createdAt AS INTEGER) < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'priority ASC, CAST(createdAt AS INTEGER) ASC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // 완료되지 않은 할 일만 조회
  Future<List<Todo>> getIncompleteTodosForToday() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'CAST(createdAt AS INTEGER) >= ? AND CAST(createdAt AS INTEGER) < ? AND isCompleted = 0',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'priority ASC, CAST(createdAt AS INTEGER) ASC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // 완료된 할 일 조회 (특정 날짜)
  Future<List<Todo>> getCompletedTodosForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'CAST(completedAt AS INTEGER) >= ? AND CAST(completedAt AS INTEGER) < ? AND isCompleted = 1',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'CAST(completedAt AS INTEGER) DESC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
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
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 오늘 완료된 할 일 개수 조회
  Future<Map<Priority, int>> getCompletedCountForToday() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'CAST(completedAt AS INTEGER) >= ? AND CAST(completedAt AS INTEGER) < ? AND isCompleted = 1',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
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
      where: 'CAST(createdAt AS INTEGER) >= ? AND CAST(createdAt AS INTEGER) < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
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
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
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