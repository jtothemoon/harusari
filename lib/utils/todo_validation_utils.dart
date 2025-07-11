import '../models/todo.dart';
import '../utils/constants.dart';

/// 1-3-5 법칙 검증을 담당하는 유틸리티 클래스
///
/// 1-3-5 법칙:
/// - 중요도 높음 (High): 최대 1개
/// - 중요도 보통 (Medium): 최대 3개
/// - 중요도 낮음 (Low): 최대 5개
///
/// 이 클래스는 할 일 추가/수정 시 위 법칙을 검증하고,
/// 사용자에게 적절한 피드백을 제공합니다.
class TodoValidationUtils {
  /// 1-3-5 법칙에 따라 새로운 할 일을 추가할 수 있는지 검증
  static bool canAddTodo(Priority priority, List<Todo> todos) {
    final counts = _getPriorityCounts(todos);

    switch (priority) {
      case Priority.high:
        return counts[Priority.high]! < AppConstants.maxHighPriorityTodos;
      case Priority.medium:
        return counts[Priority.medium]! < AppConstants.maxMediumPriorityTodos;
      case Priority.low:
        return counts[Priority.low]! < AppConstants.maxLowPriorityTodos;
    }
  }

  /// 다음에 추가할 우선순위 추천
  static Priority getRecommendedPriority(List<Todo> todos) {
    final counts = _getPriorityCounts(todos);

    if (counts[Priority.high]! < 1) return Priority.high;
    if (counts[Priority.medium]! < 3) return Priority.medium;
    if (counts[Priority.low]! < 5) return Priority.low;
    return Priority.low; // 기본값
  }

  /// 각 우선순위별 남은 개수 계산
  static int getRemainingCount(Priority priority, List<Todo> todos) {
    final counts = _getPriorityCounts(todos);

    switch (priority) {
      case Priority.high:
        return AppConstants.maxHighPriorityTodos - counts[Priority.high]!;
      case Priority.medium:
        return AppConstants.maxMediumPriorityTodos - counts[Priority.medium]!;
      case Priority.low:
        return AppConstants.maxLowPriorityTodos - counts[Priority.low]!;
    }
  }

  /// 우선순위 제한 메시지 반환
  static String getPriorityLimitMessage(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppConstants.priorityHighLimitMessage;
      case Priority.medium:
        return AppConstants.priorityMediumLimitMessage;
      case Priority.low:
        return AppConstants.priorityLowLimitMessage;
    }
  }

  /// 우선순위별 개수 계산 (private 헬퍼 메서드)
  static Map<Priority, int> _getPriorityCounts(List<Todo> todos) {
    return {
      Priority.high: todos
          .where((todo) => todo.priority == Priority.high)
          .length,
      Priority.medium: todos
          .where((todo) => todo.priority == Priority.medium)
          .length,
      Priority.low: todos.where((todo) => todo.priority == Priority.low).length,
    };
  }

  /// 할 일 수정 시 우선순위 변경이 가능한지 검증
  static bool canUpdateTodoPriority(
    int todoId,
    Priority newPriority,
    List<Todo> todos,
  ) {
    // 기존 할 일을 제외한 임시 리스트 생성
    final tempTodos = todos.where((todo) => todo.id != todoId).toList();

    // 새로운 우선순위로 추가 가능한지 검증
    return canAddTodo(newPriority, tempTodos);
  }
}
