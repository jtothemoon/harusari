import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../theme/app_colors.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final bool isEditing;
  final VoidCallback? onTap;
  final VoidCallback? onEditingCancelled;
  final ValueChanged<bool?>? onCheckboxChanged;
  final Function(String, Priority, Function(bool))? onUpdate;
  final VoidCallback? onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    this.isEditing = false,
    this.onTap,
    this.onEditingCancelled,
    this.onCheckboxChanged,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  late TextEditingController _textController;
  late Priority _currentPriority;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.todo.title);
    _currentPriority = widget.todo.priority;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _buildEditingCard();
    }

    return _buildNormalCard();
  }

  Widget _buildNormalCard() {
    return Dismissible(
      key: Key('todo_${widget.todo.id ?? UniqueKey()}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog();
      },
      onDismissed: (direction) {
        widget.onDelete?.call();
      },
      background: _buildSwipeBackground(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.getDividerColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(context),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: _getPriorityColor(widget.todo.priority),
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                // 편집 가능한 영역 (우선순위 아이콘 + 제목)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 우선순위 아이콘
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getPriorityBackgroundColor(
                                widget.todo.priority,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              _getPriorityIcon(widget.todo.priority),
                              size: 12,
                              color: _getPriorityColor(widget.todo.priority),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 할 일 제목
                          Expanded(
                            child: Text(
                              widget.todo.title,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getTextPrimaryColor(context),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 체크박스 영역 (더 큰 터치 영역)
                _buildNotionCheckbox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getPriorityColor(_currentPriority),
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 우선순위 아이콘
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getPriorityBackgroundColor(_currentPriority),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        _getPriorityIcon(_currentPriority),
                        size: 12,
                        color: _getPriorityColor(_currentPriority),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 텍스트 입력 필드
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextPrimaryColor(context),
                          height: 1.4,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        autofocus: true,
                        onSubmitted: (value) => _saveChanges(),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 편집 버튼들
                    _buildEditButtons(),
                  ],
                ),

                const SizedBox(height: 12),

                // 우선순위 선택 버튼들
                _buildPrioritySelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotionCheckbox() {
    return GestureDetector(
      onTap: () => _toggleComplete(),
      child: Container(
        padding: const EdgeInsets.all(16), // 더 큰 터치 영역
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: widget.todo.isCompleted
                ? AppColors.success
                : Colors.transparent,
            border: Border.all(
              color: widget.todo.isCompleted
                  ? AppColors.success
                  : Theme.of(context).brightness == Brightness.dark
                  ? AppColors
                        .darkTextSecondary // 다크테마에서 더 밝은 색상
                  : AppColors.getDividerColor(context),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.todo.isCompleted
              ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
              : null,
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: [
        _buildPriorityButton(Priority.high, '중요', AppColors.priorityHigh),
        const SizedBox(width: 8),
        _buildPriorityButton(Priority.medium, '보통', AppColors.priorityMedium),
        const SizedBox(width: 8),
        _buildPriorityButton(Priority.low, '낮음', AppColors.priorityLow),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.getDividerColor(context),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected
                ? color
                : AppColors.getTextSecondaryColor(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
    );
  }

  Widget _buildEditButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 저장 버튼
        GestureDetector(
          onTap: _saveChanges,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              LucideIcons.check,
              color: AppColors.success,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 취소 버튼
        GestureDetector(
          onTap: _cancelEdit,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(LucideIcons.x, color: AppColors.error, size: 16),
          ),
        ),
      ],
    );
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

  Color _getPriorityBackgroundColor(Priority priority) {
    // 테마에 따라 동적으로 배경색 결정
    return AppColors.getPriorityBackgroundColor(
      context,
      priority.toString().split('.').last,
    );
  }

  void _saveChanges() {
    final newTitle = _textController.text.trim();
    if (newTitle.isNotEmpty) {
      widget.onUpdate?.call(newTitle, _currentPriority, (success) {
        if (success) {
          widget.onEditingCancelled?.call();
        }
      });
    } else {
      widget.onEditingCancelled?.call();
    }
  }

  void _cancelEdit() {
    _textController.text = widget.todo.title;
    _currentPriority = widget.todo.priority;
    widget.onEditingCancelled?.call();
  }

  void _toggleComplete() {
    if (widget.todo.isCompleted) {
      // 이미 완료된 할 일은 되돌리기 불가
      return;
    }

    // 완료 처리
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    todoProvider.completeTodo(widget.todo.id!);
    widget.onCheckboxChanged?.call(true);
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
        ) ??
        false;
  }
}
