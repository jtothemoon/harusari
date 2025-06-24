import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import 'dart:async';

class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;
  
  // Undo 기능을 위한 상태
  Todo? _lastCompletedTodo;
  Timer? _undoTimer;

  // Getters
  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Todo? get lastCompletedTodo => _lastCompletedTodo;

  // 우선순위별 할 일 개수
  int get highPriorityCount => _todos.where((todo) => todo.priority == Priority.high).length;
  int get mediumPriorityCount => _todos.where((todo) => todo.priority == Priority.medium).length;
  int get lowPriorityCount => _todos.where((todo) => todo.priority == Priority.low).length;

  // 오늘의 할 일 로드
  Future<void> loadTodosForToday() async {
    _setLoading(true);
    try {
      _todos = await _databaseService.getIncompleteTodosForToday();
      _error = null;
    } catch (e) {
      _error = '할 일을 불러오는데 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 할 일 추가
  Future<void> addTodo(String title, Priority priority) async {
    if (title.trim().isEmpty) return;

    final todo = Todo(
      title: title.trim(),
      priority: priority,
      createdAt: DateTime.now(),
    );

    try {
      final id = await _databaseService.insertTodo(todo);
      final newTodo = todo.copyWith(id: id);
      _todos.add(newTodo);
      _sortTodos();
      notifyListeners();
    } catch (e) {
      _error = '할 일을 추가하는데 실패했습니다: $e';
      notifyListeners();
    }
  }

  // 할 일 완료 처리
  Future<void> completeTodo(int id) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        final todo = _todos[index];
        final completedTodo = todo.markAsCompleted();
        
        await _databaseService.updateTodo(completedTodo);
        _todos.removeAt(index);
        _lastCompletedTodo = completedTodo;
        notifyListeners();
        
        // 5초 후 Undo 타이머 시작
        _startUndoTimer();
      }
    } catch (e) {
      _error = '할 일을 완료하는데 실패했습니다: $e';
      notifyListeners();
    }
  }

  // 할 일 수정
  Future<void> updateTodo(int id, String title, Priority priority) async {
    if (title.trim().isEmpty) return;

    try {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        final todo = _todos[index];
        final updatedTodo = todo.copyWith(
          title: title.trim(),
          priority: priority,
        );
        
        await _databaseService.updateTodo(updatedTodo);
        _todos[index] = updatedTodo;
        _sortTodos();
        notifyListeners();
      }
    } catch (e) {
      _error = '할 일을 수정하는데 실패했습니다: $e';
      notifyListeners();
    }
  }

  // 할 일 삭제
  Future<void> deleteTodo(int id) async {
    try {
      await _databaseService.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      _error = '할 일을 삭제하는데 실패했습니다: $e';
      notifyListeners();
    }
  }

  // 완료된 할 일 조회 (특정 날짜)
  Future<List<Todo>> getCompletedTodosForDate(DateTime date) async {
    try {
      return await _databaseService.getCompletedTodosForDate(date);
    } catch (e) {
      _error = '완료된 할 일을 불러오는데 실패했습니다: $e';
      notifyListeners();
      return [];
    }
  }

  // 오늘 완료된 할 일 개수 조회
  Future<Map<Priority, int>> getCompletedCountForToday() async {
    try {
      return await _databaseService.getCompletedCountForToday();
    } catch (e) {
      _error = '완료 개수를 불러오는데 실패했습니다: $e';
      notifyListeners();
      return {Priority.high: 0, Priority.medium: 0, Priority.low: 0};
    }
  }

  // 오늘 생성된 할 일 개수 조회
  Future<Map<Priority, int>> getCreatedCountForToday() async {
    try {
      return await _databaseService.getCreatedCountForToday();
    } catch (e) {
      _error = '생성 개수를 불러오는데 실패했습니다: $e';
      notifyListeners();
      return {Priority.high: 0, Priority.medium: 0, Priority.low: 0};
    }
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 할 일 정렬 (우선순위별)
  void _sortTodos() {
    _todos.sort((a, b) {
      // 우선순위 순서: high -> medium -> low
      if (a.priority != b.priority) {
        return a.priority.index.compareTo(b.priority.index);
      }
      // 같은 우선순위면 생성 시간순
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  // 1-3-5 법칙 검증
  bool canAddTodo(Priority priority) {
    switch (priority) {
      case Priority.high:
        return highPriorityCount < 1;
      case Priority.medium:
        return mediumPriorityCount < 3;
      case Priority.low:
        return lowPriorityCount < 5;
    }
  }

  // 다음 우선순위 추천
  Priority getRecommendedPriority() {
    if (highPriorityCount < 1) return Priority.high;
    if (mediumPriorityCount < 3) return Priority.medium;
    if (lowPriorityCount < 5) return Priority.low;
    return Priority.low; // 기본값
  }

  // Undo 기능
  Future<void> undoLastCompletion() async {
    if (_lastCompletedTodo != null) {
      try {
        final restoredTodo = _lastCompletedTodo!.markAsIncomplete();
        await _databaseService.updateTodo(restoredTodo);
        _todos.add(restoredTodo);
        _sortTodos();
        _lastCompletedTodo = null;
        _cancelUndoTimer();
        notifyListeners();
      } catch (e) {
        _error = '할 일을 되돌리는데 실패했습니다: $e';
        notifyListeners();
      }
    }
  }

  // Undo 타이머 시작
  void _startUndoTimer() {
    _cancelUndoTimer();
    _undoTimer = Timer(const Duration(seconds: 5), () {
      _lastCompletedTodo = null;
      notifyListeners();
    });
  }

  // Undo 타이머 취소
  void _cancelUndoTimer() {
    _undoTimer?.cancel();
    _undoTimer = null;
  }
} 