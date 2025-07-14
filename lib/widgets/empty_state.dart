import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class EmptyState extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final bool isCompact;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onActionPressed,
    this.actionText,
    this.isCompact = false,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(widget.isCompact ? 16.0 : 32.0),
            child: Column(
              mainAxisAlignment: widget.isCompact
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              mainAxisSize: widget.isCompact
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: [
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.isCompact ? 80 : 120,
                    height: widget.isCompact ? 80 : 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(widget.isCompact ? 12 : 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: widget.isCompact ? 32 : 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: widget.isCompact ? 16 : 24),
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimaryColor(context),
                          fontSize: widget.isCompact ? 16 : 20,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: widget.isCompact ? 8 : 12),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: AppColors.getTextSecondaryColor(context),
                          height: 1.5,
                          fontSize: widget.isCompact ? 14 : 16,
                          letterSpacing: -0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.onActionPressed != null &&
                          widget.actionText != null) ...[
                        SizedBox(height: widget.isCompact ? 20 : 28),
                        ElevatedButton.icon(
                          onPressed: widget.onActionPressed,
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: Text(
                            widget.actionText!,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: widget.isCompact ? 14 : 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isCompact ? 20 : 28,
                              vertical: widget.isCompact ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 사전 정의된 빈 상태들
class EmptyStates {
  static Widget noTodos({VoidCallback? onAddPressed}) {
    return EmptyState(
      icon: LucideIcons.clipboardList,
      title: '할 일이 없어요',
      subtitle: '오늘은 어떤 목표를 세워볼까요?\n1-3-5 법칙으로 부담 없이 시작해보세요!',
      actionText: '첫 할 일 추가하기',
      onActionPressed: onAddPressed,
    );
  }

  static Widget allCompleted() {
    return const EmptyState(
      icon: LucideIcons.partyPopper,
      title: '모든 할 일 완료! 🎉',
      subtitle: '오늘도 정말 수고하셨어요!\n내일은 또 다른 목표로 함께해요.',
    );
  }

  static Widget noCompletedTodos() {
    return const EmptyState(
      icon: LucideIcons.calendar,
      title: '완료된 할 일이 없어요',
      subtitle: '이 날짜에는 완료된 할 일이 없습니다.\n다른 날짜를 선택해보세요.',
      isCompact: true,
    );
  }
}
