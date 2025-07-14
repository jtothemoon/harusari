import 'package:flutter/material.dart';
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
  late PageController _controller;
  int _currentPage = 0;

  // 온보딩 페이지 데이터
  final List<OnboardingContent> _contents = [
    OnboardingContent(
      icon: Icons.auto_awesome,
      color: AppColors.priorityHigh,
      title: "하루살이에 오신 것을 환영해요!",
      desc: "매일 새로운 시작, 간단하게 관리하세요\n복잡한 일정 관리는 그만!\n하루에 집중할 수 있는 할 일만 선택하세요",
    ),
    OnboardingContent(
      icon: Icons.priority_high,
      color: AppColors.priorityMedium,
      title: "1-3-5 법칙으로 우선순위 설정",
      desc: "중요한 것부터 차근차근\n하루에 중요한 일 1개, 중간 일 3개, 작은 일 5개\n과부하 없이 효율적으로 관리하세요",
    ),
    OnboardingContent(
      icon: Icons.calendar_month,
      color: AppColors.priorityLow,
      title: "달력으로 한눈에 보는 성취",
      desc: "당신의 성장을 시각화하세요\n완료한 할 일들을 달력에서 확인하고\n꾸준한 성취감을 느껴보세요",
    ),
    OnboardingContent(
      icon: Icons.rocket_launch,
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
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.getDividerColor(context),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 22 : 10,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 아이콘 이미지
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: _buildPageImage(
                              _contents[i].icon,
                              _contents[i].color,
                            ),
                          ),
                        ),

                        // 텍스트 영역
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 제목
                              Text(
                                _contents[i].title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimaryColor(context),
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 설명
                              Text(
                                _contents[i].desc,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.getTextSecondaryColor(
                                    context,
                                  ),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 하단 컨트롤
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 왼쪽 버튼 (건너뛰기 또는 이전)
                  Expanded(
                    child: _currentPage == 0
                        ? TextButton(
                            onPressed: _finishOnboarding,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.getTextSecondaryColor(
                                context,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "건너뛰기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.getTextSecondaryColor(
                                context,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "이전",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ),

                  // 가운데 점 인디케이터
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _contents.length,
                        (int index) => _buildDots(index: index),
                      ),
                    ),
                  ),

                  // 오른쪽 버튼 (다음 또는 시작하기)
                  Expanded(
                    child: TextButton(
                      onPressed: _currentPage == _contents.length - 1
                          ? _finishOnboarding
                          : () {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                              );
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _currentPage == _contents.length - 1 ? "시작하기" : "다음",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
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
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 80, color: color),
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
