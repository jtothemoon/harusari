import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:typed_data' show Int64List;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android 설정
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;

    if (kDebugMode) {
      print('알림 서비스 초기화 완료');
    }
  }

  // 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('알림 탭됨: ${response.payload}');
    }
    // 필요시 특정 화면으로 이동하는 로직 추가
  }

  // 권한 요청
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    // Android 권한 요청
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      bool? result = await androidImplementation
          ?.requestNotificationsPermission();

      if (kDebugMode) {
        print('Android 알림 권한 요청 결과: $result');
      }

      return result ?? false;
    }

    // iOS 권한 요청
    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      bool? result = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        print('iOS 알림 권한 요청 결과: $result');
      }

      return result ?? false;
    }

    return false;
  }

  // 권한 상태 확인
  Future<bool> hasPermissions() async {
    if (!_isInitialized) await initialize();

    // Android 권한 확인
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      bool? result = await androidImplementation?.areNotificationsEnabled();
      return result ?? false;
    }

    // iOS는 권한 확인이 제한적이므로 요청 시도
    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      bool? result = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return result ?? false;
    }

    return false;
  }

  // 하루 시작 알림 표시
  Future<void> showDayStartNotification({bool enableVibration = true}) async {
    if (!_isInitialized) await initialize();

    // 진동 설정에 따라 다른 채널 사용
    final String channelId = enableVibration
        ? 'day_start_vibration'
        : 'day_start_no_vibration';
    final String channelName = enableVibration
        ? '하루 시작 알림 (진동)'
        : '하루 시작 알림 (진동 없음)';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: '새로운 하루가 시작될 때 알림을 받습니다',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: enableVibration,
          vibrationPattern: enableVibration
              ? Int64List.fromList([0, 1000, 500, 1000])
              : null,
          playSound: true,
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: enableVibration, // 진동 설정에 따라 사운드도 제어
      badgeNumber: 1,
      // iOS에서는 시스템 설정을 따르므로 앱에서 진동 제어가 제한적
      // 하지만 사운드를 끄면 진동도 함께 제어됨
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      '🌅 하루가 초기화되었습니다!',
      '🌱 어제 못한 일은 신경 쓰지 마세요. 오늘 하루만 생각해요!',
      notificationDetails,
      payload: 'day_start',
    );

    if (kDebugMode) {
      print('하루 시작 알림 표시됨 (진동: $enableVibration, 채널: $channelId)');
    }
  }

  // 스케줄된 알림 취소
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    if (kDebugMode) {
      print('모든 알림 취소됨');
    }
  }

  // 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // 배지 설정 (iOS 전용, Android는 자동)
  Future<void> setBadgeCount(int count) async {
    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      // iOS에서는 로컬 알림을 통해 배지 설정
      if (count > 0) {
        await _flutterLocalNotificationsPlugin.show(
          999, // 배지 전용 ID
          null,
          null,
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: false,
              presentBadge: true,
              presentSound: false,
              badgeNumber: count,
            ),
          ),
        );
      }

      if (kDebugMode) {
        print('iOS 배지 설정: $count');
      }
    }
  }

  // 배지 초기화
  Future<void> clearBadge() async {
    try {
      if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();

        // 방법 1: 배지를 0으로 설정하는 알림 생성
        await _flutterLocalNotificationsPlugin.show(
          999, // 배지 초기화 전용 ID
          null,
          null,
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: false,
              presentBadge: true,
              presentSound: false,
              badgeNumber: 0, // 배지를 0으로 설정
            ),
          ),
        );

        // 잠시 대기 후 알림 취소
        await Future.delayed(const Duration(milliseconds: 200));
        await cancelNotification(999);

        // 방법 2: 모든 알림 취소 (iOS에서도 배지에 영향)
        await _flutterLocalNotificationsPlugin.cancelAll();

        if (kDebugMode) {
          print('iOS 배지 초기화 완료 (다중 방법 적용)');
        }
      }

      // Android에서는 모든 알림을 취소하여 배지 초기화
      if (Platform.isAndroid) {
        await _flutterLocalNotificationsPlugin.cancelAll();

        if (kDebugMode) {
          print('Android 모든 알림 취소 (배지 초기화)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('배지 초기화 중 오류: $e');
      }
    }
  }

  // 앱 포그라운드 진입 시 배지 및 알림 완전 초기화
  Future<void> clearAllNotificationsAndBadge() async {
    try {
      if (kDebugMode) {
        print('=== 앱 포그라운드 진입 - 배지 및 알림 초기화 시작 ===');
      }

      // 1. 모든 알림 취소 (알림 센터에서 제거)
      await _flutterLocalNotificationsPlugin.cancelAll();

      if (Platform.isIOS) {
        // iOS에서 배지 초기화를 위한 강화된 방법
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();

        // 방법 1: 배지를 0으로 설정하는 알림 여러 개 생성 후 취소
        for (int i = 997; i <= 999; i++) {
          await _flutterLocalNotificationsPlugin.show(
            i,
            null,
            null,
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: false,
                presentBadge: true,
                presentSound: false,
                badgeNumber: 0,
              ),
            ),
          );
        }

        // 잠시 대기
        await Future.delayed(const Duration(milliseconds: 300));

        // 모든 배지 초기화 알림 취소
        for (int i = 997; i <= 999; i++) {
          await cancelNotification(i);
        }

        // 방법 2: 다시 한 번 모든 알림 취소
        await _flutterLocalNotificationsPlugin.cancelAll();

        if (kDebugMode) {
          print('iOS 배지 및 알림 완전 초기화 완료');
        }
      }

      if (Platform.isAndroid) {
        // Android에서는 추가로 한 번 더 취소
        await Future.delayed(const Duration(milliseconds: 100));
        await _flutterLocalNotificationsPlugin.cancelAll();

        if (kDebugMode) {
          print('Android 배지 및 알림 완전 초기화 완료');
        }
      }

      if (kDebugMode) {
        print('=== 배지 및 알림 완전 초기화 완료 ===');
      }
    } catch (e) {
      if (kDebugMode) {
        print('배지 및 알림 완전 초기화 중 오류: $e');
      }
    }
  }

  // 배지 개수 증가
  Future<void> incrementBadge() async {
    if (Platform.isIOS) {
      // iOS에서는 현재 배지 개수를 알기 어려우므로 1로 설정
      await setBadgeCount(1);

      if (kDebugMode) {
        print('iOS 배지 증가');
      }
    }
  }

  // 배지 상태 확인 (디버깅용)
  Future<void> checkBadgeStatus() async {
    if (kDebugMode) {
      print('=== 배지 상태 확인 ===');
      print('플랫폼: ${Platform.isIOS ? 'iOS' : 'Android'}');

      // 활성 알림 개수 확인 (Android 전용)
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        final List<ActiveNotification>? activeNotifications =
            await androidImplementation?.getActiveNotifications();

        print('활성 알림 개수: ${activeNotifications?.length ?? 0}');
      }

      print('==================');
    }
  }
}
