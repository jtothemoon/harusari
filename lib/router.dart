import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/onboarding_service.dart';
import 'theme/app_colors.dart';

// 라우트 이름 상수
class Routes {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
}

// 라우터 설정
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.home,
  redirect: (context, state) async {
    // 온보딩 완료 여부 확인
    final isOnboardingCompleted =
        await OnboardingService.isOnboardingCompleted();

    // 온보딩 화면이 아닌데 온보딩이 완료되지 않은 경우
    if (!isOnboardingCompleted && state.uri.path != Routes.onboarding) {
      return Routes.onboarding;
    }

    // 온보딩이 완료된 상태에서 온보딩 화면으로 가려는 경우
    if (isOnboardingCompleted && state.uri.path == Routes.onboarding) {
      return Routes.home;
    }

    return null; // 리다이렉트 없음
  },
  routes: [
    // 온보딩 화면 (독립적인 라우트)
    GoRoute(
      path: Routes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // 메인 쉘 라우트 (하단 네비게이션바 포함)
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.calendar,
          name: 'calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: Routes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

// 메인 쉘 (하단 네비게이션바 포함)
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // 현재 경로에 따라 선택된 인덱스 업데이트
  void _updateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    switch (location) {
      case Routes.home:
        _selectedIndex = 0;
        break;
      case Routes.calendar:
        _selectedIndex = 1;
        break;
      case Routes.settings:
        _selectedIndex = 2;
        break;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.calendar);
        break;
      case 2:
        context.go(Routes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBackgroundColor(context),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(context),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: LucideIcons.sparkles,
                  label: '오늘',
                  index: 0,
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                _buildNavItem(
                  icon: LucideIcons.calendar,
                  label: '달력',
                  index: 1,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                _buildNavItem(
                  icon: LucideIcons.settings,
                  label: '설정',
                  index: 2,
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextSecondaryColor(context),
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
