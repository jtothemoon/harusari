import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/colors.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;
  final Function(String, Priority, Function(bool))? onUpdate;
  final VoidCallback? onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    this.onTap,
    this.onCheckboxChanged,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> with TickerProviderStateMixin {
  bool _isEditing = false;
  late TextEditingController _textController;
  late Priority _currentPriority;
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.todo.title);
    _currentPriority = widget.todo.priority;
    
    // 애니메이션 컨트롤러 초기화
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      // 편집 모드일 때는 Dismissible 없이 Card만 반환
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 우선순위 색상 띠
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPriorityColor(_currentPriority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildEditMode()),
              const SizedBox(width: 16),
              _buildEditButtons(),
            ],
          ),
        ),
      );
    }
    // 평상시에는 Dismissible + GestureDetector로 클릭/스와이프 모두 동작
    return Dismissible(
      key: Key('todo_${widget.todo.id ?? UniqueKey()}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog();
      },
      onDismissed: (direction) {
        widget.onDelete?.call();
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isEditing = true;
          });
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 우선순위 색상 띠
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_currentPriority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.todo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: GestureDetector(
                        onTapDown: (_) {
                          _scaleController.forward();
                        },
                        onTapUp: (_) {
                          _scaleController.reverse();
                          _checkController.forward().then((_) {
                            widget.onCheckboxChanged?.call(true);
                          });
                        },
                        onTapCancel: () {
                          _scaleController.reverse();
                        },
                        child: AnimatedBuilder(
                          animation: _checkAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _checkAnimation.value > 0.5 
                                    ? AppColors.priorityHigh 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppColors.priorityHigh,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _checkAnimation.value > 0.5
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          autofocus: true,
          onSubmitted: (value) => _saveChanges(),
        ),
        const SizedBox(height: 8),
        // 우선순위 선택 버튼들
        Row(
          children: [
            _buildPriorityButton(Priority.high, '중요', AppColors.priorityHigh),
            const SizedBox(width: 8),
            _buildPriorityButton(Priority.medium, '보통', AppColors.priorityMedium),
            const SizedBox(width: 8),
            _buildPriorityButton(Priority.low, '낮음', AppColors.priorityLow),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityButton(Priority priority, String label, Color color) {
    final isSelected = _currentPriority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: color,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 저장 버튼
        IconButton(
          onPressed: _saveChanges,
          icon: const Icon(
            Icons.check,
            color: AppColors.priorityLow,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        // 취소 버튼
        IconButton(
          onPressed: _cancelEdit,
          icon: const Icon(
            Icons.close,
            color: AppColors.priorityHigh,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _saveChanges() {
    final newTitle = _textController.text.trim();
    if (newTitle.isNotEmpty) {
      widget.onUpdate?.call(newTitle, _currentPriority, (success) {
        if (success) {
          setState(() {
            _isEditing = false;
          });
        }
      });
    } else {
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _textController.text = widget.todo.title;
      _currentPriority = widget.todo.priority;
    });
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: const Text('이 할 일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.priorityHigh,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    ) ?? false;
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
} 