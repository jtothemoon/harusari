import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '완료 기록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return Column(
            children: [
              // 캘린더 위젯
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(
                        context,
                      ).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar<Todo>(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  daysOfWeekVisible: true,
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
                    // 해당 날짜의 완료된 할 일 목록을 반환 (비동기 처리 불가하므로 빈 리스트 반환)
                    return [];
                  },
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      // 요일을 한 글자로 표시
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
                      return Center(
                        child: Text(
                          dayName,
                          style: TextStyle(
                            color: AppColors.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    markerBuilder: (context, day, events) {
                      return FutureBuilder<List<Todo>>(
                        future: todoProvider.getCompletedTodosForDate(day),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final completedTodos = snapshot.data!;
                          final highCount = completedTodos
                              .where((t) => t.priority == Priority.high)
                              .length;
                          final mediumCount = completedTodos
                              .where((t) => t.priority == Priority.medium)
                              .length;
                          final lowCount = completedTodos
                              .where((t) => t.priority == Priority.low)
                              .length;

                          return Positioned(
                            bottom: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (highCount > 0)
                                  Container(
                                    width: 7,
                                    height: 7,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.priorityHigh,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.getCardBackgroundColor(
                                          context,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                if (mediumCount > 0)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.priorityMedium,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.getCardBackgroundColor(
                                          context,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                if (lowCount > 0)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.priorityLow,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.getCardBackgroundColor(
                                          context,
                                        ),
                                        width: 1,
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
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                    holidayTextStyle: const TextStyle(
                      color: AppColors.priorityHigh,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.priorityHigh,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.priorityHigh.withValues(alpha: 0.3),
                      border: Border.all(
                        color: AppColors.priorityHigh,
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: AppColors.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    weekendStyle: TextStyle(
                      color: AppColors.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // 선택된 날짜 정보
              if (_selectedDay != null)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackgroundColor(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getShadowColor(
                            context,
                          ).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedDayTodos.isEmpty)
                          Expanded(child: EmptyStates.noCompletedTodos())
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: _selectedDayTodos.length,
                              itemBuilder: (context, index) {
                                final todo = _selectedDayTodos[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.getBackgroundColor(
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getPriorityColor(
                                        todo.priority,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(
                                            todo.priority,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          todo.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                AppColors.getTextPrimaryColor(
                                                  context,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: _getPriorityColor(todo.priority),
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
}
