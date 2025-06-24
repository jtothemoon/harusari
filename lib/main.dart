import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';
import 'providers/todo_provider.dart';
import 'models/todo.dart';
import 'widgets/todo_card.dart';
import 'widgets/inline_add_todo.dart';
import 'widgets/completion_snackbar.dart';

void main() {
  runApp(const HaruTodoApp());
}

class HaruTodoApp extends StatelessWidget {
  const HaruTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: MaterialApp(
        title: 'HaruTodo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.priorityHigh,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.cardBackground,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shadowColor: AppColors.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.priorityHigh,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAddingTodo = false;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 오늘의 할 일 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodosForToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HaruTodo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
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
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.priorityHigh,
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

          return Column(
            children: [
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
              // 할 일 목록
              Expanded(
                child: todoProvider.todos.isEmpty && !_isAddingTodo
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 80,
                              color: AppColors.priorityHigh,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '오늘 하루를 시작해보세요!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '1-3-5 법칙으로 할 일을 관리하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: todoProvider.todos.length,
                        itemBuilder: (context, index) {
                          final todo = todoProvider.todos[index];
                          return TodoCard(
                            todo: todo,
                            onTap: () {
                              // TODO: 할 일 편집 기능 구현 (나중 단계)
                            },
                            onCheckboxChanged: (value) {
                              if (value == true) {
                                todoProvider.completeTodo(todo.id!);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _isAddingTodo
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAddingTodo = true;
                });
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showCompletionSnackBar(BuildContext context, TodoProvider todoProvider) {
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
}
