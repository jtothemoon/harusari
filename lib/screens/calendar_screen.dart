import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
// import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/empty_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Todo> _selectedDayTodos = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadSelectedDayTodos();
  }

  Future<void> _loadSelectedDayTodos() async {
    if (_selectedDay != null) {
      final todoProvider = context.read<TodoProvider>();
      final todos = await todoProvider.getCompletedTodosForDate(_selectedDay!);

      // 우선순위별로 정렬 (빨강 → 주황 → 초록)
      todos.sort((a, b) {
        if (a.priority != b.priority) {
          return a.priority.index.compareTo(b.priority.index);
        }
        // 같은 우선순위면 완료 시간순 (최근 완료된 것부터)
        if (a.completedAt != null && b.completedAt != null) {
          return b.completedAt!.compareTo(a.completedAt!);
        }
        return 0;
      });

      setState(() {
        _selectedDayTodos = todos;
      });
    }
  }

  Future<void> _restoreTodo(Todo todo) async {
    final todoProvider = context.read<TodoProvider>();

    // 되돌리기 실행
    await todoProvider.restoreCompletedTodo(todo.id!);

    // 에러 체크
    if (todoProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              todoProvider.error!,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
        todoProvider.clearError();
      }
      return;
    }

    // 성공 시 목록 새로고침
    await _loadSelectedDayTodos();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${todo.title}을(를) 오늘 할 일로 되돌렸습니다',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('완료 기록', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          // 선택된 날짜 표시
          if (_selectedDay != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_selectedDay!.month}월 ${_selectedDay!.day}일',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final calendarHeight = (availableHeight * 0.5).clamp(
                280.0,
                350.0,
              );
              final listHeight =
                  availableHeight - calendarHeight - 32; // 32는 여백

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // 캘린더 위젯
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.getCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getShadowColor(context),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          return SizedBox(
                            height: calendarHeight,
                            child: TableCalendar<Todo>(
                              locale: 'ko_KR',
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              daysOfWeekVisible: true,
                              daysOfWeekHeight: 28, // 요일 표시 영역 높이 명시적 지정
                              rowHeight: (calendarHeight / 8).clamp(
                                40.0,
                                52.0,
                              ), // 캘린더 높이에 비례하여 조정
                              onDaySelected: (selectedDay, focusedDay) async {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                                await _loadSelectedDayTodos();
                              },
                              onPageChanged: (focusedDay) {
                                _focusedDay = focusedDay;
                              },
                              eventLoader: (day) {
                                return [];
                              },
                              calendarBuilders: CalendarBuilders(
                                dowBuilder: (context, day) {
                                  String dayName;
                                  switch (day.weekday) {
                                    case 1:
                                      dayName = '월';
                                      break;
                                    case 2:
                                      dayName = '화';
                                      break;
                                    case 3:
                                      dayName = '수';
                                      break;
                                    case 4:
                                      dayName = '목';
                                      break;
                                    case 5:
                                      dayName = '금';
                                      break;
                                    case 6:
                                      dayName = '토';
                                      break;
                                    case 7:
                                      dayName = '일';
                                      break;
                                    default:
                                      dayName = '';
                                  }
                                  return Container(
                                    height: 24, // 명시적으로 높이 지정
                                    alignment: Alignment.center,
                                    child: Text(
                                      dayName,
                                      style: TextStyle(
                                        color: AppColors.getTextSecondaryColor(
                                          context,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11, // 폰트 크기를 약간 줄임
                                        height: 1.2, // 줄 높이 조정
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                                markerBuilder: (context, day, events) {
                                  return FutureBuilder<List<Todo>>(
                                    future: todoProvider
                                        .getCompletedTodosForDate(day),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      final completedTodos = snapshot.data!;
                                      final highCount = completedTodos
                                          .where(
                                            (t) => t.priority == Priority.high,
                                          )
                                          .length;
                                      final mediumCount = completedTodos
                                          .where(
                                            (t) =>
                                                t.priority == Priority.medium,
                                          )
                                          .length;
                                      final lowCount = completedTodos
                                          .where(
                                            (t) => t.priority == Priority.low,
                                          )
                                          .length;

                                      return Positioned(
                                        bottom: 2,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (highCount > 0)
                                              Container(
                                                width: 6,
                                                height: 6,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 0.5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.priorityHigh,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            if (mediumCount > 0)
                                              Container(
                                                width: 6,
                                                height: 6,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 0.5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.priorityMedium,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            if (lowCount > 0)
                                              Container(
                                                width: 6,
                                                height: 6,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 0.5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.priorityLow,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,
                                weekendTextStyle: TextStyle(
                                  color: AppColors.getTextPrimaryColor(context),
                                ),
                                holidayTextStyle: TextStyle(
                                  color: AppColors.priorityHigh,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                defaultTextStyle: TextStyle(
                                  color: AppColors.getTextPrimaryColor(context),
                                ),
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextPrimaryColor(context),
                                ),
                                leftChevronIcon: Icon(
                                  LucideIcons.chevronLeft,
                                  color: AppColors.getTextPrimaryColor(context),
                                ),
                                rightChevronIcon: Icon(
                                  LucideIcons.chevronRight,
                                  color: AppColors.getTextPrimaryColor(context),
                                ),
                              ),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: AppColors.getTextSecondaryColor(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11, // dowBuilder와 동일한 크기로 맞춤
                                  height: 1.2, // 줄 높이 조정
                                ),
                                weekendStyle: TextStyle(
                                  color: AppColors.getTextSecondaryColor(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11, // dowBuilder와 동일한 크기로 맞춤
                                  height: 1.2, // 줄 높이 조정
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 선택된 날짜의 완료된 할 일 목록
                    if (_selectedDay != null)
                      SizedBox(
                        height: listHeight > 200
                            ? listHeight
                            : 200, // 최소 200px 보장
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.getCardBackgroundColor(context),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getShadowColor(context),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.getTextPrimaryColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedDayTodos.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_selectedDayTodos.length}개 완료',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_selectedDayTodos.isEmpty)
                                Expanded(
                                  child: Center(
                                    child: EmptyStates.noCompletedTodos(),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _selectedDayTodos.length,
                                    itemBuilder: (context, index) {
                                      final todo = _selectedDayTodos[index];
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.getBackgroundColor(
                                            context,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border(
                                            left: BorderSide(
                                              color: _getPriorityColor(
                                                todo.priority,
                                              ),
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // 우선순위 아이콘
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: _getPriorityColor(
                                                  todo.priority,
                                                ).withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: Icon(
                                                _getPriorityIcon(todo.priority),
                                                size: 10,
                                                color: _getPriorityColor(
                                                  todo.priority,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                todo.title,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.getTextPrimaryColor(
                                                        context,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            // 되돌리기 버튼
                                            InkWell(
                                              onTap: () => _restoreTodo(todo),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  LucideIcons.rotateCcw,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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
}
