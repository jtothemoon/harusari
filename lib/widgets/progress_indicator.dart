import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/colors.dart';

class TodoProgressIndicator extends StatefulWidget {
  final List<Todo> todos;
  final Duration animationDuration;

  const TodoProgressIndicator({
    super.key,
    required this.todos,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<TodoProgressIndicator> createState() => _TodoProgressIndicatorState();
}

class _TodoProgressIndicatorState extends State<TodoProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<int> _completedCountAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _updateCompletedCountAnimation();
    _controller.forward();
  }

  void _updateCompletedCountAnimation() {
    final completedCount = widget.todos.where((todo) => todo.isCompleted).length;
    _completedCountAnimation = IntTween(
      begin: 0,
      end: completedCount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(TodoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 할 일 목록이나 완료 상태가 변경되었는지 확인
    final oldCompletedCount = oldWidget.todos.where((t) => t.isCompleted).length;
    final newCompletedCount = widget.todos.where((t) => t.isCompleted).length;
    
    if (oldWidget.todos.length != widget.todos.length ||
        oldCompletedCount != newCompletedCount) {
      _updateCompletedCountAnimation();
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _completionRate {
    if (widget.todos.isEmpty) return 0.0;
    final completedCount = widget.todos.where((todo) => todo.isCompleted).length;
    return completedCount / widget.todos.length;
  }



  Color get _progressColor {
    if (_completionRate >= 1.0) return Colors.green;
    if (_completionRate >= 0.7) return AppColors.priorityMedium;
    if (_completionRate >= 0.3) return AppColors.priorityMedium;
    return AppColors.priorityHigh;
  }

  @override
  Widget build(BuildContext context) {
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
              AnimatedBuilder(
                animation: _completedCountAnimation,
                builder: (context, child) {
                  return Text(
                    '${_completedCountAnimation.value}/${widget.todos.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _progressColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _completionRate * _progressAnimation.value,
                backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            _completionRate >= 1.0
                ? '🎉 오늘의 할 일을 모두 완료했어요!'
                : _completionRate >= 0.7
                    ? '💪 거의 다 왔어요!'
                    : _completionRate >= 0.3
                        ? '🔥 좋은 페이스네요!'
                        : '🌱 차근차근 시작해봐요!',
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