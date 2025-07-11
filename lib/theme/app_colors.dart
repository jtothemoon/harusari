import 'package:flutter/material.dart';

/// 하루살이 앱에서 사용되는 색상을 정의하는 클래스입니다.
/// 1-3-5 법칙에 따른 우선순위별 색상과 앱 전반의 색상을 관리합니다.
class AppColors {
  // 생성자를 private으로 선언하여 인스턴스화 방지
  AppColors._();

  // === 우선순위별 색상 (1-3-5 법칙) ===

  /// 최우선 할 일 색상 (1개) - 부드러운 빨간색
  /// 하루에 가장 중요한 한 가지 일
  static const Color priorityHigh = Color(0xFFFF6B6B);

  /// 중간 우선순위 할 일 색상 (3개) - 부드러운 주황색
  /// 중간 사이즈의 중요한 일들
  static const Color priorityMedium = Color(0xFFFFA726);

  /// 낮은 우선순위 할 일 색상 (5개) - 부드러운 초록색
  /// 작은 일들이나 내일 해도 되는 일들
  static const Color priorityLow = Color(0xFF66BB6A);

  // === 기본 색상 ===

  /// 주 색상 - 앱의 주 색상 (우선순위 높음 색상 사용)
  static const Color primary = priorityHigh;

  /// 보조 색상 - 주 색상과 조화를 이루는 색상
  static const Color secondary = Color(0xFF03DAC6);

  // === 라이트 테마 색상 ===

  /// 앱 전체 배경색 (라이트)
  static const Color lightBackground = Color(0xFFFAFAFA);

  /// 카드 및 위젯 배경색 (라이트)
  static const Color lightCardBackground = Colors.white;

  /// 표면 색상 (라이트)
  static const Color lightSurface = Colors.white;

  /// 주 텍스트 색상 (라이트)
  static const Color lightTextPrimary = Color(0xFF212121);

  /// 보조 텍스트 색상 (라이트)
  static const Color lightTextSecondary = Color(0xFF757575);

  /// 비활성화된 텍스트 색상 (라이트)
  static const Color lightTextDisabled = Color(0xFFBDBDBD);

  /// 구분선 색상 (라이트)
  static const Color lightDivider = Color(0xFFE0E0E0);

  /// 그림자 색상 (라이트)
  static const Color lightShadow = Color(0x1A000000);

  // === 다크 테마 색상 ===

  /// 앱 전체 배경색 (다크)
  static const Color darkBackground = Color(0xFF121212);

  /// 카드 및 위젯 배경색 (다크)
  static const Color darkCardBackground = Color(0xFF1E1E1E);

  /// 표면 색상 (다크)
  static const Color darkSurface = Color(0xFF2D2D2D);

  /// 주 텍스트 색상 (다크)
  static const Color darkTextPrimary = Color(0xFFE0E0E0);

  /// 보조 텍스트 색상 (다크)
  static const Color darkTextSecondary = Color(0xFFB3B3B3);

  /// 비활성화된 텍스트 색상 (다크)
  static const Color darkTextDisabled = Color(0xFF6D6D6D);

  /// 구분선 색상 (다크)
  static const Color darkDivider = Color(0xFF3D3D3D);

  /// 그림자 색상 (다크)
  static const Color darkShadow = Color(0x40000000);

  // === 공통 색상 ===

  /// 에러 색상
  static const Color error = Color(0xFFB00020);

  /// 성공 색상
  static const Color success = Color(0xFF4CAF50);

  /// 경고 색상
  static const Color warning = Color(0xFFFF9800);

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
