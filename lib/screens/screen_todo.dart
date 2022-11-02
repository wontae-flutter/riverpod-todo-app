import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:todo_app/models/model_todo.dart';
import 'package:todo_app/providers/provider_todo.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final newTodoController = TextEditingController();
    //* 터치 외의 빈공간 눌렀을 때 자동으로 키보드가 사라지게 하기
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Todo Screen"),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          children: [
            const Title(),
            TextField(
              controller: newTodoController,
              decoration: InputDecoration(labelText: "What needs to be done?"),
              onSubmitted: (value) {
                ref.read(todoListProvider.notifier).addTodo(value);
                newTodoController.clear();
              },
            ),
            const SizedBox(
              height: 42,
            ),
            const Toolbar(),
            //* 요렇게 조건절 바로 사용 가능
            if (filteredTodos.isNotEmpty) const Divider(height: 0),
            for (var i = 0; i < filteredTodos.length; i++) ...[
              if (i > 0) const Divider(height: 0),
              Dismissible(
                key: ValueKey(filteredTodos[i].id),
                onDismissed: (direction) {
                  ref
                      .read(todoListProvider.notifier)
                      .removeTodo(filteredTodos[i]);
                },
                child: ProviderScope(
                  overrides: [
                    _currentTodo.overrideWithValue(filteredTodos[i]),
                  ],
                  child: const TodoItem(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "todos",
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Color.fromARGB(38, 47, 47, 247),
          fontSize: 100,
          fontWeight: FontWeight.w100,
          fontFamily: "Helvetica Neue"),
    );
  }
}

class Toolbar extends ConsumerWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoListFilterProvider);
    Color? textColorFor(TodoListFilter value) {
      return filter == value ? Colors.blue : Colors.black;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "${ref.watch(uncompletedTodosCountProvider)} items left",
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Tooltip(
          message: "All todos",
          child: TextButton(
            onPressed: () => ref.read(todoListFilterProvider.notifier).state =
                TodoListFilter.all,
            style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                    textColorFor(TodoListFilter.all))),
            child: Text("All"),
          ),
        ),
        Tooltip(
          message: "Only uncompleted todos",
          child: TextButton(
            onPressed: () => ref.read(todoListFilterProvider.notifier).state =
                TodoListFilter.active,
            style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                    textColorFor(TodoListFilter.active))),
            child: Text("Active"),
          ),
        ),
        Tooltip(
          message: "Only completed todos",
          child: TextButton(
            onPressed: () => ref.read(todoListFilterProvider.notifier).state =
                TodoListFilter.completed,
            style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                    textColorFor(TodoListFilter.completed))),
            child: Text("Done"),
          ),
        ),
      ],
    );
  }
}

//* A Provider that exposes the Todo displayed by a TodoItem
//* By retrieving the Todo through a provider instead of through its constructor,
//* this allows TodoItem to be instantiated using the const keyword.
//? 최적화 가능, only the impacted widgets rebuilds, instead of the entire.
final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

class TodoItem extends HookConsumerWidget {
  const TodoItem({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    final itemFocusNode = useFocusNode();
    final isItemFocused = useIsFocused(itemFocusNode);

    final textEditingController = TextEditingController();
    final textFieldFocusNode = useFocusNode();

    //* 완전 날것의 Material 위젯
    return Material(
        color: Colors.white,
        elevation: 6,
        child: Focus(
          focusNode: itemFocusNode,
          onFocusChange: (focused) {
            if (focused) {
              textEditingController.text = todo.description;
            } else {
              //* Only commit changes when the textfield is unfocused, for performance
              ref.read(todoListProvider.notifier).editTodo(
                  id: todo.id, description: textEditingController.text);
            }
          },
          child: ListTile(
            onTap: () {
              itemFocusNode.requestFocus();
              textFieldFocusNode.requestFocus();
            },
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) =>
                  ref.read(todoListProvider.notifier).toggle(todo.id),
            ),
            title: isItemFocused
                ? TextField(
                    autofocus: true,
                    focusNode: textFieldFocusNode,
                    controller: textEditingController,
                  )
                : Text(todo.description),
          ),
        ));
  }
}

//? Flutter Hook
bool useIsFocused(FocusNode node) {
  final isFocused = useState(node.hasFocus);

  useEffect(() {
    void listener() {
      isFocused.value = node.hasFocus;
    }

    node.addListener(listener);
    return () => node.removeListener(listener);
  }, [node]);

  return isFocused.value;
}
