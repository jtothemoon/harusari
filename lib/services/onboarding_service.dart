import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _onboardingVersionKey = 'onboarding_version';

  // 현재 온보딩 버전 (온보딩 내용이 바뀔 때마다 증가)
  static const int currentOnboardingVersion = 1;

  /// 온보딩 완료 여부 확인
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_onboardingKey) ?? false;
    final version = prefs.getInt(_onboardingVersionKey) ?? 0;

    // 온보딩 버전이 다르면 다시 보여주기
    return isCompleted && version >= currentOnboardingVersion;
  }

  /// 온보딩 완료 상태 저장
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    await prefs.setInt(_onboardingVersionKey, currentOnboardingVersion);
  }

  /// 온보딩 상태 초기화 (개발/테스트용)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_onboardingVersionKey);
  }

  /// 온보딩을 본 날짜 저장 (선택사항)
  static Future<void> saveOnboardingDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_date', DateTime.now().toIso8601String());
  }

  /// 온보딩을 본 날짜 가져오기
  static Future<DateTime?> getOnboardingDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('onboarding_date');
    return dateString != null ? DateTime.parse(dateString) : null;
  }
}
