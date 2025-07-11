import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/inline_add_todo.dart';
import '../widgets/completion_snackbar.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/empty_state.dart';
import '../widgets/common_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAddingTodo = false;
  int? _editingTodoId; // 현재 편집 중인 할 일의 ID

  @override
  void initState() {
    super.initState();

    // main.dart의 AppInitializer에서 이미 초기화 완료
    // 추가 초기화 작업이 필요하면 여기서 처리
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '오늘의 할 일'),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          // 완료 처리 시 스낵바 표시
          if (todoProvider.lastCompletedTodo != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCompletionSnackBar(context, todoProvider);
            });
          }

          // 하루 시작 알림 표시
          if (todoProvider.shouldShowDayStartNotification) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showDayStartNotification(context, todoProvider);
            });
          }

          if (todoProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: AppColors.priorityMedium,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '할 일을 불러오는 중...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            );
          }

          if (todoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.priorityHigh,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오류가 발생했습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todoProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      todoProvider.clearError();
                      todoProvider.loadTodosForToday();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final incompleteTodos = todoProvider.todos
              .where((todo) => !todo.isCompleted)
              .toList();

          return Column(
            children: [
              // 진행률 표시기
              if (todoProvider.todos.isNotEmpty)
                TodoProgressIndicator(todos: todoProvider.todos),

              // 인라인 할 일 추가 위젯 (편집 모드일 때만 표시)
              if (_isAddingTodo)
                InlineAddTodo(
                  onAdd: (title, priority) async {
                    // 1-3-5 법칙 검증
                    if (!todoProvider.canAddTodo(priority)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _getPriorityLimitMessage(priority),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppColors.priorityHigh,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      return;
                    }

                    await todoProvider.addTodo(title, priority);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '할 일이 추가되었습니다!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppColors.priorityLow,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }

                    // 편집 모드 종료
                    setState(() {
                      _isAddingTodo = false;
                    });
                  },
                  onCancel: () {
                    setState(() {
                      _isAddingTodo = false;
                    });
                  },
                ),

              // 할 일 목록 (미완료만)
              Expanded(
                child: todoProvider.todos.isEmpty && !_isAddingTodo
                    ? EmptyStates.noTodos(
                        onAddPressed: () {
                          setState(() {
                            _isAddingTodo = true;
                          });
                        },
                      )
                    : incompleteTodos.isEmpty && !_isAddingTodo
                    ? EmptyStates.allCompleted()
                    : AnimationLimiter(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: incompleteTodos.length,
                          itemBuilder: (context, index) {
                            final todo = incompleteTodos[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: TodoCard(
                                      key: Key('todo_card_${todo.id}'),
                                      todo: todo,
                                      isEditing: _editingTodoId == todo.id,
                                      onTap: () {
                                        // 카드 클릭 시 편집 모드로 전환
                                        setState(() {
                                          _editingTodoId = todo.id;
                                        });
                                      },
                                      onEditingCancelled: () {
                                        // 편집 취소 시 상태 초기화
                                        setState(() {
                                          _editingTodoId = null;
                                        });
                                      },
                                      onCheckboxChanged: (value) {
                                        if (value == true) {
                                          todoProvider.completeTodo(todo.id!);
                                        }
                                      },
                                      onUpdate:
                                          (title, priority, callback) async {
                                            await todoProvider.updateTodo(
                                              todo.id!,
                                              title,
                                              priority,
                                            );
                                            if (todoProvider.error != null) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      todoProvider.error!,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        AppColors.priorityHigh,
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
                                              todoProvider.clearError();
                                              callback(false); // 실패
                                              return;
                                            }
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '할 일이 수정되었습니다!',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.priorityMedium,
                                                  duration: Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            }
                                            callback(true); // 성공
                                            // 편집 완료 후 상태 초기화
                                            setState(() {
                                              _editingTodoId = null;
                                            });
                                          },
                                      onDelete: () async {
                                        await todoProvider.deleteTodo(todo.id!);

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '할 일이 삭제되었습니다',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor:
                                                  AppColors.priorityHigh,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return AnimatedScale(
            scale: _isAddingTodo || todoProvider.todos.isEmpty ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAddingTodo = true;
                  _editingTodoId = null; // 새로운 할 일 추가 시 편집 상태 초기화
                });
              },
              backgroundColor: AppColors.priorityMedium,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  void _showCompletionSnackBar(
    BuildContext context,
    TodoProvider todoProvider,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CompletionSnackBar(
          onUndo: () {
            todoProvider.undoLastCompletion();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDayStartNotification(
    BuildContext context,
    TodoProvider todoProvider,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🌅 하루가 초기화되었습니다!\n🌱 어제 못한 일은 신경 쓰지 마세요. 오늘 하루만 생각해요!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.priorityMedium,
        duration: Duration(seconds: 4),
      ),
    );
    todoProvider.clearDayStartNotification();
  }

  String _getPriorityLimitMessage(Priority priority) {
    switch (priority) {
      case Priority.high:
        return '가장 중요한 일은 1개만 추가할 수 있습니다';
      case Priority.medium:
        return '중간 사이즈의 일은 3개까지 추가할 수 있습니다';
      case Priority.low:
        return '작은 일은 5개까지 추가할 수 있습니다';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
