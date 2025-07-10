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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAddingTodo = false;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 Provider 초기화 및 오늘의 할 일 로드
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final todoProvider = context.read<TodoProvider>();
        await todoProvider.initialize();
        await todoProvider.loadTodosForToday();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('초기화 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '오늘의 할 일',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          // 완료 처리 시 스낵바 표시
          if (todoProvider.lastCompletedTodo != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCompletionSnackBar(context, todoProvider);
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
                      color: AppColors.textSecondary,
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
                      color: AppColors.textSecondary,
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
                                      onTap: () {
                                        // 카드 클릭 시 편집 모드로 전환
                                        // TodoCard 내부에서 처리하므로 여기서는 빈 함수
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
