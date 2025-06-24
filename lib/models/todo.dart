enum Priority { high, medium, low }

class Todo {
  final int? id;
  final String title;
  final Priority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Todo({
    this.id,
    required this.title,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  // JSON 직렬화
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'priority': priority.index,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  // JSON 역직렬화
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      priority: Priority.values[map['priority']],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
    );
  }

  // 복사본 생성 (수정용)
  Todo copyWith({
    int? id,
    String? title,
    Priority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // 완료 처리
  Todo markAsCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  // 완료 취소
  Todo markAsIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, priority: $priority, isCompleted: $isCompleted)';
  }
} 