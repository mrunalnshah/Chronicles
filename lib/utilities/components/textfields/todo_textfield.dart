import 'package:flutter/material.dart';

class ToDoTextField extends StatefulWidget {
  final String text;
  final ValueChanged<String>? onChanged;

  const ToDoTextField({super.key, required this.text, this.onChanged});

  @override
  State<ToDoTextField> createState() => _ToDoTextFieldState();
}

class _ToDoTextFieldState extends State<ToDoTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    if (widget.text == 'Enter Task') {
      _textController = TextEditingController();
    } else {
      _textController = TextEditingController(text: widget.text);
    }
  }

  @override
  void didUpdateWidget(covariant ToDoTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _textController.text = widget.text;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter a Task',
      ),
    );
  }
}
