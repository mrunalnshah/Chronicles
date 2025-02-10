import 'package:chronicles/utilities/components/todo/todo.dart';
import 'package:flutter/material.dart';

import 'package:chronicles/services/todo_services.dart';

import 'package:chronicles/utilities/components/buttons/galactic_ocean_button.dart';
import 'package:chronicles/utilities/components/textfields/todo_textfield.dart';

final kTextStyle = TextStyle(
  fontSize: 20.0,
  color: Color(0xFFFFFFFF),
);

class CompletedTodo extends StatefulWidget {
  CompletedTodo({super.key});

  @override
  State<CompletedTodo> createState() => _CompletedTodoState();
}

class _CompletedTodoState extends State<CompletedTodo> {
  List<ToDo> listCompletedTodo = [];
  final ToDoDatabaseService _todoDB = ToDoDatabaseService.instance;
  List<ToDo> todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      todos = await _todoDB.fetchCompletedToDoTasks();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateTodo(int index, String newText) async {
    await _todoDB.updateToDoTask(todos[index].index, newText);
    setState(() {
      todos[index].content = newText;
    });
  }

  void _updateTodoStatus(int index, int status) async {
    await _todoDB.updateTodoStatus(todos[index].index, status);
    setState(() {
      todos[index].status = status;
    });
  }

  void _deleteTodo(int index) async {
    await _todoDB.deleteToDoTask(todos[index].index);
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed To-Do'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: screenHeight * 0.6,
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : todos.isEmpty
                        ? const Center(child: Text('Nothing ToDo'))
                        : ReorderableListView.builder(
                            itemCount: todos.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final item = todos.removeAt(oldIndex);
                                todos.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              ToDo todo = todos[index];
                              return ListTile(
                                key: ValueKey(todo.index),
                                title: Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.1, // Scale factor - 1.3 for 1.3 times larger
                                      child: Checkbox(
                                        value: todo.status == 1,
                                        activeColor: const Color(0xFF4EABCC), // Added const
                                        onChanged: (value) {
                                          setState(() {
                                            todo.status = value! ? 1 : 0;
                                            _updateTodoStatus(index, todo.status);
                                            _loadTodos();
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: ToDoTextField(
                                        text: todo.content,
                                        onChanged: (newText) {
                                          _updateTodo(index, newText);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                leading: const Icon(Icons.drag_indicator),
                                trailing: IconButton(
                                  icon: const Icon(Icons.cancel_outlined),
                                  onPressed: () => _deleteTodo(index),
                                ),
                              );
                            },
                          ),
              ),
            ),
            GalacticOceanButton(
              onPress: () {
                Navigator.pop(context);
              },
              buttonLabel: Text(
                'Pending ToDo',
                style: kTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
