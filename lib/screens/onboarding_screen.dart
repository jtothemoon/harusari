import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../router.dart';
import '../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          key: _introKey,
          globalBackgroundColor: AppColors.getBackgroundColor(context),
          pages: [
            // 첫 번째 페이지
            PageViewModel(
              title: "하루살이에 오신 것을 환영해요! 🎉",
              body:
                  "매일 새로운 시작, 간단하게 관리하세요\n복잡한 일정 관리는 그만! 하루에 집중할 수 있는 할 일만 선택하세요",
              image: _buildPageImage(
                Icons.auto_awesome,
                AppColors.priorityHigh,
              ),
              decoration: _getPageDecoration(),
            ),

            // 두 번째 페이지
            PageViewModel(
              title: "1-3-5 법칙으로 우선순위 설정 📋",
              body:
                  "중요한 것부터 차근차근\n하루에 중요한 일 1개, 중간 일 3개, 작은 일 5개\n과부하 없이 효율적으로 관리하세요",
              image: _buildPageImage(
                Icons.priority_high,
                AppColors.priorityMedium,
              ),
              decoration: _getPageDecoration(),
            ),

            // 세 번째 페이지
            PageViewModel(
              title: "달력으로 한눈에 보는 성취 📅",
              body: "당신의 성장을 시각화하세요\n완료한 할 일들을 달력에서 확인하고\n꾸준한 성취감을 느껴보세요",
              image: _buildPageImage(
                Icons.calendar_month,
                AppColors.priorityLow,
              ),
              decoration: _getPageDecoration(),
            ),

            // 네 번째 페이지
            PageViewModel(
              title: "지금 바로 시작해보세요! 🚀",
              body: "새로운 하루, 새로운 가능성\n오늘 할 일을 추가하고\n더 나은 하루를 만들어보세요",
              image: _buildPageImage(Icons.rocket_launch, AppColors.primary),
              decoration: _getPageDecoration(),
            ),
          ],

          // 완료 버튼 (오른쪽 아래)
          onDone: () => _finishOnboarding(),
          done: const Text(
            "시작하기",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),

          // 다음 버튼 (오른쪽 아래)
          next: const Text(
            "다음",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),

          // 스킵 버튼 (오른쪽 상단)
          onSkip: () => _finishOnboarding(),
          showSkipButton: true,
          skip: const Text(
            "건너뛰기",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),

          // 이전 버튼 (왼쪽 아래)
          showBackButton: true,
          back: const Text(
            "이전",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),

          // 버튼 스타일
          nextStyle: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          doneStyle: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          backStyle: TextButton.styleFrom(
            foregroundColor: AppColors.getTextSecondaryColor(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),

          skipStyle: TextButton.styleFrom(
            foregroundColor: AppColors.getTextSecondaryColor(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          // 점 인디케이터 스타일
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: AppColors.getDividerColor(context),
            activeSize: const Size(22.0, 10.0),
            activeColor: AppColors.primary,
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),

          // 레이아웃 설정
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),

          // 애니메이션 설정
          animationDuration: 300,
          curve: Curves.easeInOut,

          // 스와이프 활성화
          allowImplicitScrolling: true,
        ),
      ),
    );
  }

  Widget _buildPageImage(IconData icon, Color color) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 80, color: color),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextPrimaryColor(context),
        height: 1.3,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        color: AppColors.getTextSecondaryColor(context),
        height: 1.5,
      ),
      pageColor: AppColors.getBackgroundColor(context),
      imagePadding: const EdgeInsets.only(top: 40, bottom: 40),
      titlePadding: const EdgeInsets.only(bottom: 16),
    );
  }

  void _finishOnboarding() async {
    // 온보딩 완료 상태 저장
    await OnboardingService.setOnboardingCompleted();
    await OnboardingService.saveOnboardingDate();

    if (mounted) {
      context.go(Routes.home);
    }
  }
}
