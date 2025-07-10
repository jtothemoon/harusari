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

  // === 배경 및 표면 색상 ===

  /// 앱 전체 배경색
  static const Color background = Color(0xFFFAFAFA);

  /// 카드 및 위젯 배경색
  static const Color cardBackground = Colors.white;

  /// 표면 색상 (다이얼로그, 바텀시트 등)
  static const Color surface = Colors.white;

  // === 텍스트 색상 ===

  /// 주 텍스트 색상
  static const Color textPrimary = Color(0xFF212121);

  /// 보조 텍스트 색상 (설명, 부가 정보)
  static const Color textSecondary = Color(0xFF757575);

  /// 비활성화된 텍스트 색상
  static const Color textDisabled = Color(0xFFBDBDBD);

  // === UI 요소 색상 ===

  /// 그림자 색상
  static const Color shadow = Color(0x1A000000);

  /// 구분선 색상
  static const Color divider = Color(0xFFE0E0E0);

  /// 에러 색상
  static const Color error = Color(0xFFB00020);

  /// 성공 색상
  static const Color success = Color(0xFF4CAF50);

  /// 경고 색상
  static const Color warning = Color(0xFFFF9800);

  // === 다크 테마 색상 (필요시 사용) ===

  /// 다크 테마 배경색
  static const Color darkBackground = Color(0xFF121212);

  /// 다크 테마 카드 배경색
  static const Color darkCardBackground = Color(0xFF1E1E1E);

  /// 다크 테마 주 텍스트 색상
  static const Color darkTextPrimary = Colors.white;

  /// 다크 테마 보조 텍스트 색상
  static const Color darkTextSecondary = Color(0xFFB3B3B3);

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
