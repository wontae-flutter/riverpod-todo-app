import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/model_todo.dart';
import 'package:todo_app/notifiers/notifier_todo.dart';

//* Creates a TodoList and initialise it with pre-defined values
//* use StateNotifierProvider as List<Todo> is a complex object with CRUD operations.
final todoListProvider =
    StateNotifierProvider<TodosNotifier, List<Todo>>((ref) {
  return TodosNotifier(const [
    Todo(id: 'todo-0', description: 'hi'),
    Todo(id: 'todo-1', description: 'hello'),
    Todo(id: 'todo-2', description: 'bonjour'),
  ]);
});

enum TodoListFilter {
  all,
  active,
  completed,
}

//* StateProvider for the filter, as it is just enum
//? Default Value: ALL
final todoListFilterProvider = StateProvider((ref) => TodoListFilter.all);

//* By using Provider, we can cache his value, making it performant
//? This means even multiple widgets try to read the value at once,
//? the value will be computed only once (before the value changes)
//? This also optimizes unneeded rebuilds, like the todo list changes,
//? but the number of uncompleted remains the same
final uncompletedTodosCountProvider = Provider<int>((ref) {
  return ref.watch(todoListProvider).where((todo) => !todo.isCompleted).length;
});

//* Todolist after applying TodoListFilter
//? Provider lets avoiding recomputing the filtered list unless either the filter or Todolist modifies.
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.isCompleted).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.isCompleted).toList();
    case TodoListFilter.all:
      return todos;
  }
});
