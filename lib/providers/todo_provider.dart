import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/day_transition_service.dart';
import '../services/timer_manager.dart';
import '../utils/todo_validation_utils.dart';
import 'settings_provider.dart';

/// 할 일 관리를 담당하는 Provider 클래스
///
/// 1-3-5 법칙을 기반으로 한 할 일 관리 시스템:
/// - 중요도 높음: 최대 1개
/// - 중요도 보통: 최대 3개
/// - 중요도 낮음: 최대 5개
///
/// 주요 기능:
/// - 할 일 CRUD 작업
/// - Undo 기능 (5초 타이머)
/// - 하루 전환 기능 (설정된 시간에 미완료 할 일 자동 삭제)
/// - 1-3-5 법칙 검증
class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final TimerManager _timerManager = TimerManager();
  final DayTransitionService _dayTransitionService = DayTransitionService();

  // SettingsProvider 참조 (타이머 콜백에서 안전하게 사용)
  SettingsProvider? _settingsProvider;

  // ==========================================
  // 상태 변수들
  // ==========================================
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  // Undo 기능을 위한 상태
  Todo? _lastCompletedTodo;

  // 하루 시작 알림 상태
  bool _shouldShowDayStartNotification = false;

  // 캐싱
  DateTime? _lastLoadedDate;

  // ==========================================
  // Getters
  // ==========================================
  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Todo? get lastCompletedTodo => _lastCompletedTodo;
  bool get shouldShowDayStartNotification => _shouldShowDayStartNotification;
  DatabaseService get databaseService => _databaseService;

  // 우선순위별 개수 (완료된 할 일도 포함 - 1-3-5 법칙)
  int get highPriorityCount =>
      _todos.where((todo) => todo.priority == Priority.high).length;
  int get mediumPriorityCount =>
      _todos.where((todo) => todo.priority == Priority.medium).length;
  int get lowPriorityCount =>
      _todos.where((todo) => todo.priority == Priority.low).length;

  // ==========================================
  // 할 일 관리 메서드들
  // ==========================================
  // 오늘의 할 일 로드 (완료된 것도 포함)
  Future<void> loadTodosForToday() async {
    final today = DateTime.now();

    // 같은 날이면 캐시에서 가져오기 (단, 미완료 할일이 있는 경우에만)
    if (_lastLoadedDate != null &&
        _lastLoadedDate!.year == today.year &&
        _lastLoadedDate!.month == today.month &&
        _lastLoadedDate!.day == today.day &&
        _todos.any((todo) => !todo.isCompleted)) {
      return;
    }

    _setLoading(true);
    try {
      _todos = await _databaseService.getTodosForToday();
      _lastLoadedDate = today;
      _error = null;
    } catch (e) {
      _error = '할 일을 불러오는데 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 캐시를 무시하고 강제로 오늘의 할 일 로드
  Future<void> forceLoadTodosForToday() async {
    final today = DateTime.now();

    _setLoading(true);
    try {
      _todos = await _databaseService.getTodosForToday();
      _lastLoadedDate = today;
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

        // 즉시 UI 업데이트
        notifyListeners();

        // 5초 후 Undo 타이머 시작
        _timerManager.startUndoTimer(() {
          _lastCompletedTodo = null;
          notifyListeners();
        });
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
          // 기존 할 일을 제외한 검증
          bool canUpdate = TodoValidationUtils.canUpdateTodoPriority(
            todo.id!,
            priority,
            _todos,
          );

          if (!canUpdate) {
            _error = TodoValidationUtils.getPriorityLimitMessage(priority);
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
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
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
    return TodoValidationUtils.canAddTodo(priority, _todos);
  }

  // 다음 우선순위 추천
  Priority getRecommendedPriority() {
    return TodoValidationUtils.getRecommendedPriority(_todos);
  }

  // 각 우선순위별 남은 개수 계산
  int getRemainingCount(Priority priority) {
    return TodoValidationUtils.getRemainingCount(priority, _todos);
  }

  // ==========================================
  // Undo 기능 관련 메서드들
  // ==========================================

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
        _timerManager.cancelUndoTimer();
        notifyListeners();
      } catch (e) {
        _error = '할 일을 되돌리는데 실패했습니다: $e';
        notifyListeners();
      }
    }
  }

  // 완료된 할 일을 미완료 상태로 되돌리기 (캘린더에서 사용)
  Future<void> restoreCompletedTodo(int todoId) async {
    try {
      // 데이터베이스에서 해당 할 일 조회
      final todo = await _databaseService.getTodoById(todoId);
      if (todo == null) {
        _error = '할 일을 찾을 수 없습니다';
        notifyListeners();
        return;
      }

      // 완료된 할 일이 아니면 처리하지 않음
      if (!todo.isCompleted) {
        _error = '이미 미완료 상태인 할 일입니다';
        notifyListeners();
        return;
      }

      // 1-3-5 법칙 검증 (오늘 날짜 기준 - 미완료 할 일만 체크)
      final today = DateTime.now();
      final todayIncompleteTodos = await _databaseService
          .getIncompleteTodosForToday();

      bool canRestore = TodoValidationUtils.canAddTodo(
        todo.priority,
        todayIncompleteTodos,
      );
      if (!canRestore) {
        _error = TodoValidationUtils.getPriorityLimitMessage(todo.priority);
        notifyListeners();
        return;
      }

      // 할 일을 오늘 날짜로 복원하고 미완료 상태로 변경
      final restoredTodo = todo.copyWith(
        isCompleted: false,
        completedAt: null,
        createdAt: DateTime.now(), // 오늘 날짜로 변경
      );

      await _databaseService.updateTodo(restoredTodo);

      // 오늘 할 일 목록에 추가
      _todos.add(restoredTodo);
      _sortTodos();
      notifyListeners();

      // 홈 화면에서 즉시 반영되도록 강제 새로고침
      await forceLoadTodosForToday();
    } catch (e) {
      _error = '할 일을 되돌리는데 실패했습니다: $e';
      notifyListeners();
    }
  }

  // ==========================================
  // 초기화 메서드들
  // ==========================================

  // Provider 초기화
  Future<void> initialize(BuildContext context) async {
    // SettingsProvider 참조 저장
    _settingsProvider = context.read<SettingsProvider>();

    // 할 일 로드
    await loadTodosForToday();

    // 하루 전환 기능 활성화
    await _setupDayTransition();
  }

  /// 하루 전환 기능 설정
  Future<void> _setupDayTransition() async {
    try {
      if (_settingsProvider == null) return;

      final dayStartTime = _settingsProvider!.dayStartTime;

      // 타이머 설정
      _timerManager.scheduleDayTransition(dayStartTime, () {
        _performDayTransition();
      });

      if (kDebugMode) {
        print(
          '하루 전환 타이머 설정 완료: ${dayStartTime.hour}:${dayStartTime.minute.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('하루 전환 설정 실패: $e');
      }
    }
  }

  /// 하루 전환 타이머 업데이트 (설정 변경 시 호출)
  Future<void> updateDayTransitionTimer(BuildContext context) async {
    try {
      // SettingsProvider 참조 업데이트
      _settingsProvider = context.read<SettingsProvider>();

      if (_settingsProvider == null) return;

      final dayStartTime = _settingsProvider!.dayStartTime;

      // 기존 타이머 취소하고 새로 설정
      _timerManager.cancelDayTransitionTimer();
      _timerManager.scheduleDayTransition(dayStartTime, () {
        _performDayTransition();
      });

      if (kDebugMode) {
        print(
          '하루 전환 타이머 업데이트 완료: ${dayStartTime.hour}:${dayStartTime.minute.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('하루 전환 타이머 업데이트 실패: $e');
      }
    }
  }

  // 하루 전환 실행
  Future<void> _performDayTransition() async {
    try {
      if (_settingsProvider == null) {
        if (kDebugMode) {
          print('하루 전환 실행 중단: SettingsProvider가 없습니다');
        }
        return;
      }

      final result = await _dayTransitionService.performDayTransition(
        todos: _todos,
        isNotificationEnabled: _settingsProvider!.isNotificationEnabled,
        isVibrationEnabled: _settingsProvider!.isVibrationEnabled,
      );

      if (result.success) {
        // 성공 시 메모리 상태 업데이트
        _todos = result.remainingTodos;
        _shouldShowDayStartNotification = result.shouldShowNotification;
        notifyListeners();
      } else {
        // 실패 시 에러 처리
        _error = result.error;
        notifyListeners();
      }
    } catch (e) {
      _error = '하루 전환 중 오류가 발생했습니다: $e';
      notifyListeners();
      if (kDebugMode) {
        print('하루 전환 실행 오류: $e');
      }
    }
  }

  // 하루 시작 알림 플래그 리셋
  void clearDayStartNotification() {
    _shouldShowDayStartNotification = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerManager.dispose();
    super.dispose();
  }
}
