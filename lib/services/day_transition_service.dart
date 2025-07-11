import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// 하루 전환 관련 로직을 담당하는 서비스
class DayTransitionService {
  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  DayTransitionService({
    DatabaseService? databaseService,
    NotificationService? notificationService,
  }) : _databaseService = databaseService ?? DatabaseService(),
       _notificationService = notificationService ?? NotificationService();

  // ==========================================
  // 하루 전환 시점 계산
  // ==========================================

  /// 다음 하루 전환 시점을 계산합니다
  DateTime calculateNextTransitionTime(TimeOfDay dayStartTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTransition = today.add(
      Duration(hours: dayStartTime.hour, minutes: dayStartTime.minute),
    );

    DateTime nextTransition;
    if (now.isBefore(todayTransition)) {
      // 오늘의 전환 시간이 아직 안 지났으면 오늘로 설정
      nextTransition = todayTransition;
    } else {
      // 오늘의 전환 시간이 지났으면 내일로 설정
      nextTransition = todayTransition.add(const Duration(days: 1));
    }

    if (kDebugMode) {
      final timeUntilTransition = nextTransition.difference(now);
      print(
        '다음 하루 전환: ${nextTransition.toString()}, ${timeUntilTransition.inMinutes}분 후',
      );
    }

    return nextTransition;
  }

  /// 현재 시간이 하루 전환 시간을 지났는지 확인합니다
  bool shouldPerformDayTransition(TimeOfDay dayStartTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTransition = today.add(
      Duration(hours: dayStartTime.hour, minutes: dayStartTime.minute),
    );

    return now.isAfter(todayTransition);
  }

  // ==========================================
  // 하루 전환 실행
  // ==========================================

  /// 하루 전환을 실행합니다
  ///
  /// [todos]: 현재 할 일 목록
  /// [isNotificationEnabled]: 알림 설정 여부
  /// [isVibrationEnabled]: 진동 설정 여부
  ///
  /// Returns: 업데이트된 할 일 목록 (완료된 할 일만 남음)
  Future<DayTransitionResult> performDayTransition({
    required List<Todo> todos,
    required bool isNotificationEnabled,
    required bool isVibrationEnabled,
  }) async {
    try {
      // 미완료 할 일들을 찾습니다
      final incompleteTodos = todos.where((todo) => !todo.isCompleted).toList();

      if (kDebugMode) {
        print('하루 전환 시작: ${incompleteTodos.length}개의 미완료 할 일 발견');
      }

      // 데이터베이스에서 미완료 할 일들을 삭제합니다
      for (final todo in incompleteTodos) {
        await _databaseService.deleteTodo(todo.id!);
        if (kDebugMode) {
          print('삭제된 할 일: ${todo.title}');
        }
      }

      // 완료된 할 일들만 남깁니다
      final remainingTodos = todos.where((todo) => todo.isCompleted).toList();

      // 알림 설정에 따라 푸시 알림 발송
      if (isNotificationEnabled) {
        await _notificationService.showDayStartNotification(
          enableVibration: isVibrationEnabled,
        );
      }

      if (kDebugMode) {
        print('하루 전환 완료: ${incompleteTodos.length}개의 미완료 할 일이 삭제되었습니다.');
        print('남은 할 일: ${remainingTodos.length}개');
      }

      return DayTransitionResult(
        success: true,
        deletedTodosCount: incompleteTodos.length,
        remainingTodos: remainingTodos,
        shouldShowNotification: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('하루 전환 오류: $e');
      }

      return DayTransitionResult(
        success: false,
        error: '하루 전환 중 오류가 발생했습니다: $e',
        deletedTodosCount: 0,
        remainingTodos: todos,
        shouldShowNotification: false,
      );
    }
  }

  // ==========================================
  // 앱 시작 시 하루 전환 체크 (현재 비활성화)
  // ==========================================

  /// 앱 시작 시 하루 전환이 필요한지 확인합니다
  ///
  /// 현재는 비활성화되어 있습니다.
  /// 필요시 이 메서드를 사용하여 앱 시작 시 자동 하루 전환을 구현할 수 있습니다.
  Future<bool> checkAndPerformDayTransitionOnAppStart({
    required TimeOfDay dayStartTime,
    required List<Todo> todos,
    required bool isNotificationEnabled,
    required bool isVibrationEnabled,
  }) async {
    if (!shouldPerformDayTransition(dayStartTime)) {
      return false;
    }

    if (kDebugMode) {
      print('앱 시작 시 하루 전환 필요');
    }

    final result = await performDayTransition(
      todos: todos,
      isNotificationEnabled: isNotificationEnabled,
      isVibrationEnabled: isVibrationEnabled,
    );

    return result.success;
  }
}

/// 하루 전환 결과를 담는 클래스
class DayTransitionResult {
  final bool success;
  final String? error;
  final int deletedTodosCount;
  final List<Todo> remainingTodos;
  final bool shouldShowNotification;

  DayTransitionResult({
    required this.success,
    this.error,
    required this.deletedTodosCount,
    required this.remainingTodos,
    required this.shouldShowNotification,
  });
}
