class AppConstants {
  // 1-3-5 법칙 제한
  static const int maxHighPriorityTodos = 1;
  static const int maxMediumPriorityTodos = 3;
  static const int maxLowPriorityTodos = 5;

  // 애니메이션 지속시간
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 375);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // 타이머 지속시간
  static const Duration undoTimerDuration = Duration(seconds: 5);
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration shortSnackBarDuration = Duration(seconds: 1);

  // 기본 설정값
  static const int defaultDayStartHour = 6;
  static const int defaultDayStartMinute = 0;

  // 데이터베이스 관련
  static const String databaseName = 'harutodo.db';
  static const int databaseVersion = 2;

  // 설정 키
  static const String dayStartHourKey = 'day_start_hour';
  static const String dayStartMinuteKey = 'day_start_minute';

  // 메시지
  static const String priorityHighLimitMessage = '가장 중요한 일은 1개만 추가할 수 있습니다';
  static const String priorityMediumLimitMessage = '중간 사이즈의 일은 3개까지 추가할 수 있습니다';
  static const String priorityLowLimitMessage = '작은 일은 5개까지 추가할 수 있습니다';
} 