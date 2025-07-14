import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/todo.dart';
import '../theme/app_colors.dart';

class TodoProgressIndicator extends StatefulWidget {
  final List<Todo> todos;

  const TodoProgressIndicator({super.key, required this.todos});

  @override
  State<TodoProgressIndicator> createState() => _TodoProgressIndicatorState();
}

class _TodoProgressIndicatorState extends State<TodoProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.todos
        .where((todo) => todo.isCompleted)
        .length;
    final totalCount = widget.todos.length;
    final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

    Color progressColor;
    String message;
    IconData progressIcon;

    if (completionRate >= 1.0) {
      progressColor = AppColors.success;
      message = '모든 할 일을 완료했어요!';
      progressIcon = LucideIcons.partyPopper;
    } else if (completionRate >= 0.7) {
      progressColor = AppColors.priorityMedium;
      message = '거의 다 왔어요!';
      progressIcon = LucideIcons.trendingUp;
    } else if (completionRate >= 0.3) {
      progressColor = AppColors.priorityMedium;
      message = '좋은 페이스네요!';
      progressIcon = LucideIcons.flame;
    } else {
      progressColor = AppColors.primary;
      message = '차근차근 시작해봐요!';
      progressIcon = LucideIcons.sun;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDividerColor(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(progressIcon, size: 20, color: progressColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 진행률',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimaryColor(context),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$completedCount/$totalCount',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.getDividerColor(context),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    height: 6,
                    width:
                        MediaQuery.of(context).size.width *
                        (completionRate * _progressAnimation.value),
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (completionRate < 1.0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '남은 할 일',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityStatus(AppColors.priorityHigh, '중요'),
                      const SizedBox(width: 16),
                      _buildPriorityStatus(AppColors.priorityMedium, '보통'),
                      const SizedBox(width: 16),
                      _buildPriorityStatus(AppColors.priorityLow, '낮음'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityStatus(Color color, String label) {
    final count = widget.todos
        .where(
          (todo) =>
              !todo.isCompleted &&
              _getPriorityFromColor(color) == todo.priority,
        )
        .length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $count개',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.getTextSecondaryColor(context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Priority _getPriorityFromColor(Color color) {
    if (color == AppColors.priorityHigh) return Priority.high;
    if (color == AppColors.priorityMedium) return Priority.medium;
    return Priority.low;
  }
}
