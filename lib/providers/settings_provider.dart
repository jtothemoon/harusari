import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// 앱 설정을 관리하는 Provider 클래스
///
/// 주요 기능:
/// - 알림 설정 관리
/// - 진동 설정 관리
/// - 하루 시작 시간 설정 관리
/// - 설정값 영구 저장
class SettingsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // ==========================================
  // 설정 상태 변수들
  // ==========================================
  bool _isNotificationEnabled = true;
  bool _isVibrationEnabled = true;
  TimeOfDay _dayStartTime = const TimeOfDay(hour: 6, minute: 0);

  // ==========================================
  // Getters
  // ==========================================
  bool get isNotificationEnabled => _isNotificationEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;
  TimeOfDay get dayStartTime => _dayStartTime;

  // ==========================================
  // 초기화
  // ==========================================
  Future<void> initialize() async {
    await _loadAllSettings();
    await _checkFirstLaunchAndRequestPermissions();
  }

  /// 모든 설정값을 데이터베이스에서 로드
  Future<void> _loadAllSettings() async {
    try {
      // 알림 설정 로드
      final notificationEnabled = await _databaseService.getSetting(
        'notification_enabled',
      );
      final vibrationEnabled = await _databaseService.getSetting(
        'vibration_enabled',
      );

      _isNotificationEnabled =
          notificationEnabled == 'true' ||
          notificationEnabled == null; // 기본값 true
      _isVibrationEnabled =
          vibrationEnabled == 'true' || vibrationEnabled == null; // 기본값 true

      // 하루 시작 시간 로드
      _dayStartTime = await _databaseService.getDayStartTime();

      notifyListeners();

      if (kDebugMode) {
        print(
          '설정 로드 완료 - 알림: $_isNotificationEnabled, 진동: $_isVibrationEnabled, 시작시간: ${_dayStartTime.hour}:${_dayStartTime.minute.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('설정 로드 실패: $e');
      }
    }
  }

  /// 최초 실행 시 권한 요청
  Future<void> _checkFirstLaunchAndRequestPermissions() async {
    try {
      final isFirstLaunch = await _databaseService.getSetting(
        'is_first_launch',
      );

      if (isFirstLaunch == null) {
        // 최초 실행
        if (kDebugMode) {
          print('앱 최초 실행: 알림 권한 요청');
        }

        final hasPermission = await NotificationService().requestPermissions();

        if (hasPermission) {
          // 권한 허용됨 - 알림 설정 켜기
          _isNotificationEnabled = true;
          _isVibrationEnabled = true;

          await _databaseService.saveSetting('notification_enabled', 'true');
          await _databaseService.saveSetting('vibration_enabled', 'true');

          if (kDebugMode) {
            print('알림 권한 허용됨: 알림 설정 활성화');
          }
        } else {
          // 권한 거부됨 - 알림 설정 끄기
          _isNotificationEnabled = false;
          _isVibrationEnabled = false;

          await _databaseService.saveSetting('notification_enabled', 'false');
          await _databaseService.saveSetting('vibration_enabled', 'false');

          if (kDebugMode) {
            print('알림 권한 거부됨: 알림 설정 비활성화');
          }
        }

        // 최초 실행 완료 표시
        await _databaseService.saveSetting('is_first_launch', 'false');
      } else {
        // 최초 실행이 아님 - 권한 상태만 확인
        final hasPermission = await NotificationService().hasPermissions();

        if (!hasPermission && _isNotificationEnabled) {
          // 권한이 없는데 설정은 켜져 있음 - 설정 끄기
          _isNotificationEnabled = false;
          await _databaseService.saveSetting('notification_enabled', 'false');

          if (kDebugMode) {
            print('알림 권한 없음: 알림 설정 비활성화');
          }
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('권한 확인 중 오류: $e');
      }
    }
  }

  // ==========================================
  // 알림 설정 관리
  // ==========================================
  Future<void> setNotificationEnabled(bool enabled) async {
    _isNotificationEnabled = enabled;

    // 알림이 꺼지면 진동도 자동으로 끄기 (안드로이드 동작과 일치)
    if (!enabled && _isVibrationEnabled) {
      _isVibrationEnabled = false;
      await _databaseService.saveSetting('vibration_enabled', 'false');
      if (kDebugMode) {
        print('알림 비활성화로 인해 진동도 자동 비활성화됨');
      }
    }

    notifyListeners();

    // 데이터베이스에 저장
    try {
      await _databaseService.saveSetting(
        'notification_enabled',
        enabled.toString(),
      );
      if (kDebugMode) {
        print('알림 설정 저장 완료: $enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('알림 설정 저장 실패: $e');
      }
    }
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _isVibrationEnabled = enabled;
    notifyListeners();

    // 데이터베이스에 저장
    try {
      await _databaseService.saveSetting(
        'vibration_enabled',
        enabled.toString(),
      );
      if (kDebugMode) {
        print('진동 설정 저장 완료: $enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('진동 설정 저장 실패: $e');
      }
    }
  }

  // ==========================================
  // 하루 시작 시간 관리
  // ==========================================
  Future<void> setDayStartTime(TimeOfDay time) async {
    _dayStartTime = time;
    notifyListeners();

    // 데이터베이스에 저장
    try {
      await _databaseService.saveDayStartTime(time);
      if (kDebugMode) {
        print(
          '하루 시작 시간 저장 완료: ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('하루 시작 시간 저장 실패: $e');
      }
    }
  }

  // ==========================================
  // 유틸리티 메서드
  // ==========================================

  /// 설정값들을 초기화 (개발/테스트용)
  Future<void> resetAllSettings() async {
    try {
      await _databaseService.deleteSetting('notification_enabled');
      await _databaseService.deleteSetting('vibration_enabled');
      await _databaseService.deleteSetting('day_start_hour');
      await _databaseService.deleteSetting('day_start_minute');

      // 기본값으로 복원
      _isNotificationEnabled = true;
      _isVibrationEnabled = true;
      _dayStartTime = const TimeOfDay(hour: 6, minute: 0);

      notifyListeners();

      if (kDebugMode) {
        print('모든 설정 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('설정 초기화 실패: $e');
      }
    }
  }

  /// 현재 설정 상태 출력 (디버깅용)
  void printSettings() {
    if (kDebugMode) {
      print('=== 현재 설정 상태 ===');
      print('알림: $_isNotificationEnabled');
      print('진동: $_isVibrationEnabled');
      print(
        '하루 시작 시간: ${_dayStartTime.hour}:${_dayStartTime.minute.toString().padLeft(2, '0')}',
      );
      print('====================');
    }
  }
}
