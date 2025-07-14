import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../router.dart';
import '../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;
  int _currentPage = 0;

  // 온보딩 페이지 데이터
  final List<OnboardingContent> _contents = [
    OnboardingContent(
      icon: LucideIcons.sparkles,
      color: AppColors.priorityHigh,
      title: "하루살이에 오신 것을 환영해요!",
      desc: "매일 새로운 시작, 간단하게 관리하세요\n복잡한 일정 관리는 그만!\n하루에 집중할 수 있는 할 일만 선택하세요",
    ),
    OnboardingContent(
      icon: LucideIcons.target,
      color: AppColors.priorityMedium,
      title: "1-3-5 법칙으로 우선순위 설정",
      desc: "중요한 것부터 차근차근\n하루에 중요한 일 1개, 중간 일 3개, 작은 일 5개\n과부하 없이 효율적으로 관리하세요",
    ),
    OnboardingContent(
      icon: LucideIcons.calendar,
      color: AppColors.priorityLow,
      title: "달력으로 한눈에 보는 성취",
      desc: "당신의 성장을 시각화하세요\n완료한 할 일들을 달력에서 확인하고\n꾸준한 성취감을 느껴보세요",
    ),
    OnboardingContent(
      icon: LucideIcons.rocket,
      color: AppColors.primary,
      title: "지금 바로 시작해보세요!",
      desc: "새로운 하루, 새로운 가능성\n오늘 할 일을 추가하고\n더 나은 하루를 만들어보세요",
    ),
  ];

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 점 인디케이터 빌드
  AnimatedContainer _buildDots({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.getDividerColor(context),
      ),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      curve: Curves.easeInOut,
      width: _currentPage == index ? 24 : 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // 메인 페이지뷰
            Expanded(
              flex: 3,
              child: PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: _controller,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _contents.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        // 아이콘 이미지
                        Expanded(
                          child: _buildPageImage(
                            _contents[i].icon,
                            _contents[i].color,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 제목
                        Text(
                          _contents[i].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimaryColor(context),
                            height: 1.3,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 설명
                        Text(
                          _contents[i].desc,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.getTextSecondaryColor(context),
                            height: 1.6,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 하단 컨트롤
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 점 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (int index) => _buildDots(index: index),
                    ),
                  ),

                  // 버튼들
                  _currentPage + 1 == _contents.length
                      ? Padding(
                          padding: const EdgeInsets.all(30),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _finishOnboarding,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.arrowRight, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "시작하기",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 왼쪽 버튼 (건너뛰기 또는 이전)
                              TextButton(
                                onPressed: _currentPage == 0
                                    ? _finishOnboarding
                                    : () {
                                        _controller.previousPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppColors.getTextSecondaryColor(context),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _currentPage == 0 ? "건너뛰기" : "이전",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // 오른쪽 버튼 (다음)
                              ElevatedButton(
                                onPressed: () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "다음",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      LucideIcons.chevronRight,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageImage(IconData icon, Color color) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 60, color: color),
      ),
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

// 온보딩 콘텐츠 데이터 클래스
class OnboardingContent {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  OnboardingContent({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}
