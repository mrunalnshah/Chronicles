import 'package:chronicles/utilities/components/todo/todo.dart';
import 'package:flutter/material.dart';

import 'package:chronicles/services/todo_services.dart';

class Top3ToDoList extends StatefulWidget {
  Top3ToDoList({super.key});

  @override
  State<Top3ToDoList> createState() => _Top3ToDoListState();
}

class _Top3ToDoListState extends State<Top3ToDoList> {
  final ToDoDatabaseService _todoDB = ToDoDatabaseService.instance;
  List<ToDo> todos = [];
  bool _isLoading = true;

  void _updateTodoStatus(int index, int status) async {
    await _todoDB.updateTodoStatus(todos[index].index, status);
    setState(() {
      todos[index].status = status;
    });
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      todos = await _todoDB.fetchTop3ToDos();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : todos.isEmpty
              ? const Center(child: Text('Nothing ToDo'))
              : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    ToDo todo = todos[index];
                    return ListTile(
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
                            child: Text(todo.content),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
