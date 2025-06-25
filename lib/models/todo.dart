import 'package:flutter/material.dart';

enum Priority { high, medium, low }

extension PriorityExtension on Priority {
  Color get color {
    switch (this) {
      case Priority.high:
        return const Color(0xFFE53E3E); // 빨강
      case Priority.medium:
        return const Color(0xFFDD6B20); // 주황
      case Priority.low:
        return const Color(0xFF38A169); // 초록
    }
  }

  String get displayName {
    switch (this) {
      case Priority.high:
        return '중요';
      case Priority.medium:
        return '보통';
      case Priority.low:
        return '낮음';
    }
  }
}

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
      id: map['id'] is String ? int.parse(map['id']) : map['id'],
      title: map['title'],
      priority: Priority.values[map['priority']],
      isCompleted: map['isCompleted'] == 1,
      createdAt: _parseDateTime(map['createdAt']),
      completedAt: map['completedAt'] != null 
          ? _parseDateTime(map['completedAt'])
          : null,
    );
  }

  // DateTime 파싱 헬퍼 메서드
  static DateTime _parseDateTime(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      // String인 경우 int로 파싱 시도
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return DateTime.fromMillisecondsSinceEpoch(intValue);
      }
      // ISO 형식인 경우
      return DateTime.parse(value);
    }
    throw ArgumentError('Invalid DateTime value: $value');
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