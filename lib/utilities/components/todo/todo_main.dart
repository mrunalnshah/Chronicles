import 'package:chronicles/utilities/components/buttons/galactic_ocean_button.dart';
import 'package:chronicles/utilities/components/todo/checkbox_with_label.dart';
import 'package:chronicles/utilities/components/todo/completed_todo.dart';
import 'package:flutter/material.dart';

final kTextStyle = TextStyle(
  fontFamily: 'Hind',
  fontSize: 20.0,
  color: Color(0xFFFFFFFF),
);

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<CheckboxWithLabel> todoList = [];

  void addTodoList() {
    todoList.add(
      CheckboxWithLabel(
        label: 'A',
        index: 1,
        checkboxValue: false,
      ),
    );
    todoList.add(
      CheckboxWithLabel(
        label: 'B',
        index: 2,
        checkboxValue: false,
      ),
    );
  }

  void removeTodo(index) {
    todoList.removeAt(index);
  }

  @override
  void initState() {
    super.initState();
    addTodoList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 30.0, bottom: 0.0),
              child: GalacticOceanButton(
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompletedTodo(),
                    ),
                  );
                },
                buttonLabel: Text(
                  'Completed ToDo',
                  style: kTextStyle,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: screenHeight * 0.6,
                width: double.infinity,
                child: ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = todoList.removeAt(oldIndex);
                      todoList.insert(newIndex, item);
                    });
                  },
                  children: List.generate(
                    todoList.length,
                    (index) {
                      return Row(
                        key: ValueKey(todoList[index]),
                        children: [
                          const Icon(Icons.drag_indicator),
                          Expanded(
                            child: todoList[index],
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                removeTodo(index);
                              });
                            },
                            icon: const Icon(Icons.cancel_outlined),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            GalacticOceanButton(
              horizontalMargin: 70.0,
              onPress: () {
                setState(
                  () {
                    todoList.add(
                      CheckboxWithLabel(
                        label: 'Enter a Task',
                        index: todoList.length + 1,
                        checkboxValue: false,
                      ),
                    );
                  },
                );
              },
              buttonLabel: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xFFFFFFFF),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Add Instant ToDo',
                    style: kTextStyle,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
