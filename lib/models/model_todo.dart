import "package:flutter/material.dart" show immutable;

@immutable
class Todo {
  final String id;
  final String description;
  final bool isCompleted;
  const Todo({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });

  @override
  String toString() {
    return 'Todo(description: $description, completed: $isCompleted)';
  }

  Todo copyWith({String? id, String? description, bool? isCompleted}) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
