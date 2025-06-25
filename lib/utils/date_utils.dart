class DateUtils {
  /// 주어진 날짜의 하루 시작 시간을 반환
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 주어진 날짜의 하루 끝 시간을 반환
  static DateTime getEndOfDay(DateTime date) {
    return getStartOfDay(date).add(const Duration(days: 1));
  }

  /// 오늘 날짜의 시작과 끝을 반환
  static (DateTime start, DateTime end) getTodayRange() {
    final today = DateTime.now();
    return (getStartOfDay(today), getEndOfDay(today));
  }

  /// 특정 날짜의 시작과 끝을 반환
  static (DateTime start, DateTime end) getDayRange(DateTime date) {
    return (getStartOfDay(date), getEndOfDay(date));
  }
} 