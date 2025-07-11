import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 앱의 모든 타이머를 관리하는 클래스
class TimerManager {
  Timer? _undoTimer;
  Timer? _dayTransitionTimer;

  // ==========================================
  // Undo 타이머 관리
  // ==========================================

  /// Undo 타이머 시작 (5초 후 콜백 실행)
  void startUndoTimer(VoidCallback onTimeout) {
    cancelUndoTimer();
    _undoTimer = Timer(const Duration(seconds: 5), onTimeout);

    if (kDebugMode) {
      print('Undo 타이머 시작: 5초 후 만료');
    }
  }

  /// Undo 타이머 취소
  void cancelUndoTimer() {
    if (_undoTimer != null) {
      _undoTimer?.cancel();
      _undoTimer = null;

      if (kDebugMode) {
        print('Undo 타이머 취소됨');
      }
    }
  }

  /// Undo 타이머가 활성화되어 있는지 확인
  bool get isUndoTimerActive => _undoTimer != null;

  // ==========================================
  // 하루 전환 타이머 관리
  // ==========================================

  /// 하루 전환 타이머 스케줄링
  void scheduleDayTransition(
    TimeOfDay dayStartTime,
    VoidCallback onDayTransition,
  ) {
    cancelDayTransitionTimer();

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

    final timeUntilTransition = nextTransition.difference(now);

    if (kDebugMode) {
      print(
        '다음 하루 전환: ${nextTransition.toString()}, ${timeUntilTransition.inMinutes}분 후',
      );
    }

    _dayTransitionTimer = Timer(timeUntilTransition, () {
      onDayTransition();
      // 다음 날 타이머 재설정
      scheduleDayTransition(dayStartTime, onDayTransition);
    });
  }

  /// 하루 전환 타이머 취소
  void cancelDayTransitionTimer() {
    if (_dayTransitionTimer != null) {
      _dayTransitionTimer?.cancel();
      _dayTransitionTimer = null;

      if (kDebugMode) {
        print('하루 전환 타이머 취소됨');
      }
    }
  }

  /// 하루 전환 타이머가 활성화되어 있는지 확인
  bool get isDayTransitionTimerActive => _dayTransitionTimer != null;

  // ==========================================
  // 정리 메서드
  // ==========================================

  /// 모든 타이머 정리
  void dispose() {
    cancelUndoTimer();
    cancelDayTransitionTimer();

    if (kDebugMode) {
      print('TimerManager 정리 완료');
    }
  }

  /// 현재 타이머 상태 출력 (디버깅용)
  void printTimerStatus() {
    if (kDebugMode) {
      print('=== TimerManager 상태 ===');
      print('Undo 타이머: ${isUndoTimerActive ? "활성화" : "비활성화"}');
      print('하루 전환 타이머: ${isDayTransitionTimerActive ? "활성화" : "비활성화"}');
      print('========================');
    }
  }
}
