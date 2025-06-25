import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/colors.dart';

class InlineAddTodo extends StatefulWidget {
  final Function(String title, Priority priority) onAdd;
  final VoidCallback? onCancel;

  const InlineAddTodo({
    super.key,
    required this.onAdd,
    this.onCancel,
  });

  @override
  State<InlineAddTodo> createState() => _InlineAddTodoState();
}

class _InlineAddTodoState extends State<InlineAddTodo> with TickerProviderStateMixin {
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _priorityAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _priorityController,
      curve: Curves.elasticOut,
    ));
    
    // 자동으로 포커스 및 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _slideController.forward();
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

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
          children: [
            // 우선순위 색상 동그라미
            AnimatedBuilder(
              animation: _priorityAnimation,
              builder: (context, child) {
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
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(_selectedPriority),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getPriorityColor(_selectedPriority).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
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
                  hintText: '오늘 하고 싶은 일을 입력하세요',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                onSubmitted: (_) => _addTodo(),
              ),
            ),
            const SizedBox(width: 8),
            // 취소 버튼
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
              ),
            ),
            // 추가 버튼
            IconButton(
              onPressed: _controller.text.trim().isNotEmpty ? _addTodo : null,
              icon: Icon(
                Icons.check_circle,
                color: _controller.text.trim().isNotEmpty 
                    ? _getPriorityColor(_selectedPriority)
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                size: 28,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _cyclePriority() {
    setState(() {
      switch (_selectedPriority) {
        case Priority.high:
          _selectedPriority = Priority.medium;
          break;
        case Priority.medium:
          _selectedPriority = Priority.low;
          break;
        case Priority.low:
          _selectedPriority = Priority.high;
          break;
      }
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

  void _addTodo() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      widget.onAdd(title, _selectedPriority);
    }
  }
} 