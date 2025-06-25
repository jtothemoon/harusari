import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  
  // 하루 전환 타이머
  Timer? _dayTransitionTimer;
  TimeOfDay _dayStartTime = const TimeOfDay(hour: 6, minute: 0);

  // Getters
  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Todo? get lastCompletedTodo => _lastCompletedTodo;
  TimeOfDay get dayStartTime => _dayStartTime;

  // 우선순위별 개수 (완료된 할 일도 포함 - 1-3-5 법칙)
  int get highPriorityCount => _todos.where((todo) => todo.priority == Priority.high).length;
  int get mediumPriorityCount => _todos.where((todo) => todo.priority == Priority.medium).length;
  int get lowPriorityCount => _todos.where((todo) => todo.priority == Priority.low).length;

  // 오늘의 할 일 로드 (완료된 것도 포함)
  Future<void> loadTodosForToday() async {
    _setLoading(true);
    try {
      _todos = await _databaseService.getTodosForToday();
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
        
        // 할 일을 제거하지 않고 상태만 업데이트
        _todos[index] = completedTodo;
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

        // 1-3-5 법칙 검증
        if (priority != todo.priority) {
          final tempTodos = List<Todo>.from(_todos)..removeAt(index);
          final tempHighCount = tempTodos.where((t) => t.priority == Priority.high).length;
          final tempMediumCount = tempTodos.where((t) => t.priority == Priority.medium).length;
          final tempLowCount = tempTodos.where((t) => t.priority == Priority.low).length;

          bool canUpdate = false;
          switch (priority) {
            case Priority.high:
              canUpdate = tempHighCount < 1;
              break;
            case Priority.medium:
              canUpdate = tempMediumCount < 3;
              break;
            case Priority.low:
              canUpdate = tempLowCount < 5;
              break;
          }
          if (!canUpdate) {
            _error = _getPriorityLimitMessage(priority);
            notifyListeners();
            return;
          }
        }

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

  String _getPriorityLimitMessage(Priority priority) {
    switch (priority) {
      case Priority.high:
        return '가장 중요한 일은 1개만 추가할 수 있습니다';
      case Priority.medium:
        return '중간 사이즈의 일은 3개까지 추가할 수 있습니다';
      case Priority.low:
        return '작은 일은 5개까지 추가할 수 있습니다';
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
        
        // 이미 리스트에 있는 할 일의 상태만 변경
        final index = _todos.indexWhere((todo) => todo.id == restoredTodo.id);
        if (index != -1) {
          _todos[index] = restoredTodo;
        }
        
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

  // 하루 시작 시간 설정
  Future<void> setDayStartTime(TimeOfDay time) async {
    // 메모리에 즉시 저장
    _dayStartTime = time;
    
    // 타이머 재설정
    _scheduleDayTransition();
    notifyListeners();
    
    // 데이터베이스에 저장 (백그라운드)
    try {
      await _databaseService.saveDayStartTime(time);
      if (kDebugMode) {
        print('하루 시작 시간 저장 완료: ${time.hour}:${time.minute.toString().padLeft(2, '0')}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('설정 저장 실패: $e');
      }
    }
  }

  // 하루 시작 시간 조회 (메모리 값 우선)
  Future<TimeOfDay> getDayStartTime() async {
    // 이미 메모리에 로드된 값이 있으면 그것을 사용
    if (_dayStartTime.hour != 6 || _dayStartTime.minute != 0) {
      return _dayStartTime;
    }
    
    // 처음 로드시에만 데이터베이스에서 읽기 시도
    try {
      final dayStartTime = await _databaseService.getDayStartTime();
      _dayStartTime = dayStartTime;
      return _dayStartTime;
    } catch (e) {
      // 데이터베이스 실패 시 기본값 사용
      if (kDebugMode) {
        print('데이터베이스 로드 실패: $e');
      }
      _dayStartTime = const TimeOfDay(hour: 6, minute: 0);
      return _dayStartTime;
    }
  }

  // 현재 메모리의 하루 시작 시간 반환 (동기)
  TimeOfDay getCurrentDayStartTime() {
    return _dayStartTime;
  }

  // Provider 초기화 시 하루 시작 시간 로드 및 타이머 설정
  Future<void> initialize() async {
    await getDayStartTime();
    
    // 앱 시작 시 하루 전환이 필요한지 체크
    await _checkAndPerformDayTransition();
    
    _scheduleDayTransition();
  }

  // 앱 시작 시 하루 전환 체크
  Future<void> _checkAndPerformDayTransition() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTransition = today.add(
      Duration(
        hours: _dayStartTime.hour,
        minutes: _dayStartTime.minute,
      ),
    );
    
    // 현재 시간이 오늘의 전환 시간을 지났는지 확인
    if (now.isAfter(todayTransition)) {
      if (kDebugMode) {
        print('앱 시작 시 하루 전환 필요: 현재 ${now.hour}:${now.minute}, 전환 시간 ${_dayStartTime.hour}:${_dayStartTime.minute}');
      }
      await _performDayTransition();
    }
  }

  // 하루 전환 타이머 스케줄링
  void _scheduleDayTransition() {
    _cancelDayTransitionTimer();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTransition = today.add(
      Duration(
        hours: _dayStartTime.hour,
        minutes: _dayStartTime.minute,
      ),
    );
    
    DateTime nextTransition;
    if (now.isBefore(todayTransition)) {
      // 오늘의 전환 시간이 아직 안 지났으면 오늘로 설정
      nextTransition = todayTransition;
    } else {
      // 오늘의 전환 시간이 지났으면 내일로 설정
      nextTransition = todayTransition.add(const Duration(days: 1));
    }
    
    final timeUntilTransition = nextTransition.difference(now);
    
    if (kDebugMode) {
      print('다음 하루 전환: ${nextTransition.toString()}, ${timeUntilTransition.inMinutes}분 후');
    }
    
    _dayTransitionTimer = Timer(timeUntilTransition, () {
      _performDayTransition();
      _scheduleDayTransition(); // 다음 날 타이머 재설정
    });
  }

  // 하루 전환 실행
  Future<void> _performDayTransition() async {
    try {
      // 미완료 할 일들을 모두 삭제
      final incompleteTodos = _todos.where((todo) => !todo.isCompleted).toList();
      
      if (kDebugMode) {
        print('하루 전환 시작: ${incompleteTodos.length}개의 미완료 할 일 발견');
      }
      
      for (final todo in incompleteTodos) {
        await _databaseService.deleteTodo(todo.id!);
        if (kDebugMode) {
          print('삭제된 할 일: ${todo.title}');
        }
      }
      
      // 메모리에서도 제거
      _todos.removeWhere((todo) => !todo.isCompleted);
      notifyListeners();
      
      if (kDebugMode) {
        print('하루 전환 완료: ${incompleteTodos.length}개의 미완료 할 일이 삭제되었습니다.');
        print('남은 할 일: ${_todos.length}개');
      }
    } catch (e) {
      _error = '하루 전환 중 오류가 발생했습니다: $e';
      notifyListeners();
      if (kDebugMode) {
        print('하루 전환 오류: $e');
      }
    }
  }

  // 하루 전환 타이머 취소
  void _cancelDayTransitionTimer() {
    _dayTransitionTimer?.cancel();
    _dayTransitionTimer = null;
  }

  @override
  void dispose() {
    _cancelUndoTimer();
    _cancelDayTransitionTimer();
    super.dispose();
  }
} 