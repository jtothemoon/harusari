import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../theme/app_colors.dart';

class TodoProgressIndicator extends StatefulWidget {
  final List<Todo> todos;

  const TodoProgressIndicator({super.key, required this.todos});

  @override
  State<TodoProgressIndicator> createState() => _TodoProgressIndicatorState();
}

class _TodoProgressIndicatorState extends State<TodoProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    final completedCount = widget.todos
        .where((todo) => todo.isCompleted)
        .length;
    final totalCount = widget.todos.length;
    final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

    Color progressColor;
    String message;

    if (completionRate >= 1.0) {
      progressColor = Colors.green;
      message = '🎉 오늘의 할 일을 모두 완료했어요!';
    } else if (completionRate >= 0.7) {
      progressColor = AppColors.priorityMedium;
      message = '💪 거의 다 왔어요!';
    } else if (completionRate >= 0.3) {
      progressColor = AppColors.priorityMedium;
      message = '🔥 좋은 페이스네요!';
    } else {
      progressColor = AppColors.priorityHigh;
      message = '🌱 차근차근 시작해봐요!';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 진행률',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$completedCount/$totalCount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionRate,
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
