import 'package:flutter/material.dart';

/// 하루살이 앱에서 사용되는 색상을 정의하는 클래스입니다.
/// Notion 스타일의 세련된 색상 시스템을 적용합니다.
class AppColors {
  // 생성자를 private으로 선언하여 인스턴스화 방지
  AppColors._();

  // === Notion 스타일 우선순위별 색상 (1-3-5 법칙) ===

  /// 최우선 할 일 색상 (1개) - 기존 시그니처 빨간색을 약간 진하게
  static const Color priorityHigh = Color(0xFFE53E3E);

  /// 중간 우선순위 할 일 색상 (3개) - 기존 시그니처 주황색을 약간 진하게
  static const Color priorityMedium = Color(0xFFDD6B20);

  /// 낮은 우선순위 할 일 색상 (5개) - 기존 시그니처 초록색을 약간 진하게
  static const Color priorityLow = Color(0xFF38A169);

  // === Notion 스타일 기본 색상 ===

  /// 주 색상 - 따뜻한 오렌지 계열
  static const Color primary = Color(0xFFFF8A65);

  /// 보조 색상 - 따뜻한 핑크 계열
  static const Color secondary = Color(0xFFFF7043);

  // === Notion 스타일 라이트 테마 색상 ===

  /// 앱 전체 배경색 (라이트) - Notion의 따뜻한 회색
  static const Color lightBackground = Color(0xFFF7F6F3);

  /// 카드 및 위젯 배경색 (라이트) - Notion의 순백색
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  /// 표면 색상 (라이트) - 약간 회색빛 도는 흰색
  static const Color lightSurface = Color(0xFFFBFBFA);

  /// 주 텍스트 색상 (라이트) - Notion의 진한 회색
  static const Color lightTextPrimary = Color(0xFF37352F);

  /// 보조 텍스트 색상 (라이트) - Notion의 중간 회색
  static const Color lightTextSecondary = Color(0xFF787774);

  /// 비활성화된 텍스트 색상 (라이트) - Notion의 연한 회색
  static const Color lightTextDisabled = Color(0xFFB4B4B4);

  /// 구분선 색상 (라이트) - Notion의 매우 연한 회색
  static const Color lightDivider = Color(0xFFE9E9E7);

  /// 그림자 색상 (라이트) - Notion의 부드러운 그림자
  static const Color lightShadow = Color(0x0A000000);

  // === Notion 스타일 다크 테마 색상 ===

  /// 앱 전체 배경색 (다크) - Notion의 진한 회색
  static const Color darkBackground = Color(0xFF191919);

  /// 카드 및 위젯 배경색 (다크) - Notion의 카드 배경
  static const Color darkCardBackground = Color(0xFF2F2F2F);

  /// 표면 색상 (다크)
  static const Color darkSurface = Color(0xFF373737);

  /// 주 텍스트 색상 (다크) - Notion의 밝은 회색
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// 보조 텍스트 색상 (다크) - Notion의 중간 회색
  static const Color darkTextSecondary = Color(0xFF9B9A97);

  /// 비활성화된 텍스트 색상 (다크)
  static const Color darkTextDisabled = Color(0xFF6D6D6D);

  /// 구분선 색상 (다크) - Notion의 다크 구분선
  static const Color darkDivider = Color(0xFF373737);

  /// 그림자 색상 (다크)
  static const Color darkShadow = Color(0x40000000);

  // === 공통 색상 ===

  /// 에러 색상 - Notion 스타일
  static const Color error = Color(0xFFE03E3E);

  /// 성공 색상 - Notion 스타일
  static const Color success = Color(0xFF0F7B0F);

  /// 경고 색상 - Notion 스타일
  static const Color warning = Color(0xFFD9730D);

  // === Notion 스타일 우선순위 배경 색상 ===

  /// 우선순위 높음 배경색 (시그니처 빨간색의 매우 연한 버전)
  static const Color priorityHighBackground = Color(0xFFFED7D7);

  /// 우선순위 중간 배경색 (시그니처 주황색의 매우 연한 버전)
  static const Color priorityMediumBackground = Color(0xFFFEEBD7);

  /// 우선순위 낮음 배경색 (시그니처 초록색의 매우 연한 버전)
  static const Color priorityLowBackground = Color(0xFFE6FFFA);

  // === 동적 색상 선택 메서드 ===

  /// 현재 테마에 따른 배경색 반환
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  /// 현재 테마에 따른 카드 배경색 반환
  static Color getCardBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : lightCardBackground;
  }

  /// 현재 테마에 따른 표면 색상 반환
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  /// 현재 테마에 따른 주 텍스트 색상 반환
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  /// 현재 테마에 따른 보조 텍스트 색상 반환
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  /// 현재 테마에 따른 비활성화 텍스트 색상 반환
  static Color getTextDisabledColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextDisabled
        : lightTextDisabled;
  }

  /// 현재 테마에 따른 구분선 색상 반환
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDivider
        : lightDivider;
  }

  /// 현재 테마에 따른 그림자 색상 반환
  static Color getShadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkShadow
        : lightShadow;
  }

  // === 유틸리티 메서드 ===

  /// 우선순위에 따른 색상 반환
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityLow;
    }
  }

  /// 색상에 투명도 적용
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
