import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/model_todo.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

//* An object that controls a list of Todo
//* This will be passed to StateNotifierProvider
class TodosNotifier extends StateNotifier<List<Todo>> {
  //! state는 은닉되어야 한다 = no public getters/properties!
  //? public method는 UI에서 사용자의 인터랙션으로 불려져서(provider.notifier.METHOD) state를 변경하게 된다
  //* initial state
  TodosNotifier([List<Todo>? initialTodos]) : super(initialTodos ?? []);

  void addTodo(String description) {
    state = [
      ...state,
      Todo(id: _uuid.v4(), description: description),
    ];
  }

  void removeTodo(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }

  void editTodo({required String id, required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
              id: todo.id,
              description: description,
              isCompleted: todo.isCompleted)
        else
          todo,
    ];
  }

  void toggle(String todoId) {
    state = [
      for (final todo in state)
        if (todo.id == todoId)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
  }
}
