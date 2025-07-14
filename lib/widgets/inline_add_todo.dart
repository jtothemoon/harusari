import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../theme/app_colors.dart';

class InlineAddTodo extends StatefulWidget {
  final Function(String title, Priority priority) onAdd;
  final VoidCallback? onCancel;

  const InlineAddTodo({super.key, required this.onAdd, this.onCancel});

  @override
  State<InlineAddTodo> createState() => _InlineAddTodoState();
}

class _InlineAddTodoState extends State<InlineAddTodo>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Priority _selectedPriority = Priority.high;
  late AnimationController _slideController;
  late AnimationController _priorityController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _priorityAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _priorityController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _priorityAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _priorityController, curve: Curves.elasticOut),
    );

    // 자동으로 포커스 및 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _slideController.forward();

      // 초기 우선순위를 사용 가능한 것으로 설정
      _setInitialPriority();
    });

    // 텍스트 변경 리스너 추가 (버튼 상태 업데이트용)
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    _focusNode.dispose();
    _slideController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      // 버튼 활성화 상태만 업데이트
    });
  }

  void _setInitialPriority() {
    final todoProvider = context.read<TodoProvider>();

    // 사용 가능한 우선순위 찾기 (높음 → 중간 → 낮음 순서)
    if (todoProvider.getRemainingCount(Priority.high) > 0) {
      setState(() {
        _selectedPriority = Priority.high;
      });
    } else if (todoProvider.getRemainingCount(Priority.medium) > 0) {
      setState(() {
        _selectedPriority = Priority.medium;
      });
    } else if (todoProvider.getRemainingCount(Priority.low) > 0) {
      setState(() {
        _selectedPriority = Priority.low;
      });
    }
    // 모든 우선순위가 꽉 찬 경우는 기본값(Priority.high) 유지
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 우선순위 선택 영역
                      AnimatedBuilder(
                        animation: _priorityAnimation,
                        builder: (context, child) {
                          final remainingCount = todoProvider.getRemainingCount(
                            _selectedPriority,
                          );
                          return Transform.scale(
                            scale: _priorityAnimation.value,
                            child: GestureDetector(
                              onTap: () {
                                _cyclePriority();
                                _priorityController.forward().then((_) {
                                  _priorityController.reverse();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    _selectedPriority,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getPriorityColor(_selectedPriority),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getPriorityIcon(_selectedPriority),
                                      size: 16,
                                      color: _getPriorityColor(
                                        _selectedPriority,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getPriorityText(_selectedPriority),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _getPriorityColor(
                                              _selectedPriority,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(
                                          _selectedPriority,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        remainingCount.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // 텍스트 입력 필드
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: '할 일을 입력하세요...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.getTextSecondaryColor(
                                    context,
                                  ).withValues(alpha: 0.6),
                                ),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.getTextPrimaryColor(context),
                              ),
                          onSubmitted: (_) => _addTodo(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 버튼들
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 추가 버튼
                          GestureDetector(
                            onTap: _controller.text.trim().isNotEmpty
                                ? _addTodo
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _controller.text.trim().isNotEmpty
                                    ? AppColors.success
                                    : AppColors.getTextSecondaryColor(
                                        context,
                                      ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: _controller.text.trim().isNotEmpty
                                    ? Colors.white
                                    : AppColors.getTextSecondaryColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 취소 버튼
                          GestureDetector(
                            onTap: widget.onCancel,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 우선순위 설명
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.lightbulb,
                          size: 16,
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '1-3-5 법칙: 중요한 일 1개, 보통 일 3개, 작은 일 5개까지',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.getTextSecondaryColor(
                                    context,
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
          ),
        );
      },
    );
  }

  void _cyclePriority() {
    final todoProvider = context.read<TodoProvider>();

    setState(() {
      Priority nextPriority;
      switch (_selectedPriority) {
        case Priority.high:
          nextPriority = Priority.medium;
          break;
        case Priority.medium:
          nextPriority = Priority.low;
          break;
        case Priority.low:
          nextPriority = Priority.high;
          break;
      }

      // 남은 개수가 0인 중요도는 건너뛰기
      int attempts = 0;
      while (todoProvider.getRemainingCount(nextPriority) <= 0 &&
          attempts < 3) {
        switch (nextPriority) {
          case Priority.high:
            nextPriority = Priority.medium;
            break;
          case Priority.medium:
            nextPriority = Priority.low;
            break;
          case Priority.low:
            nextPriority = Priority.high;
            break;
        }
        attempts++;
      }

      _selectedPriority = nextPriority;
    });
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return '높음';
      case Priority.medium:
        return '중간';
      case Priority.low:
        return '낮음';
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Icons.circle; // ● 진한 빨간색 - 꽉 찬 동그라미
      case Priority.medium:
        return Icons.circle; // ● 연한 주황색 - 꽉 찬 동그라미
      case Priority.low:
        return Icons.radio_button_unchecked; // ○ 초록색 - 빈 동그라미
    }
  }

  void _addTodo() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      widget.onAdd(title, _selectedPriority);
    }
  }
}
