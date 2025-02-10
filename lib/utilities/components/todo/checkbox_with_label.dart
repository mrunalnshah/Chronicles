import 'package:flutter/material.dart';

final checkboxLabelTextStyle = TextStyle(
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  fontSize: 16.0,
);

class CheckboxWithLabel extends StatefulWidget {
  int index;
  bool checkboxValue = false;
  String label = 'XYZ';
  TextEditingController text;

  CheckboxWithLabel({
    super.key,
    required this.label,
    required this.index,
    required this.checkboxValue,
  }) : text = TextEditingController(text: label);

  @override
  State<CheckboxWithLabel> createState() => _CheckboxWithLabelState();
}

class _CheckboxWithLabelState extends State<CheckboxWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: widget.checkboxValue,
              onChanged: (value) {
                setState(
                  () {
                    widget.checkboxValue = value!;
                  },
                );
              },
              checkColor: Color(0xFFFFFFFF),
              activeColor: Color(0xFF4EABCC),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(5.0), // Adjust the radius as needed
              ),
              side: BorderSide(
                color: Color(0xFF1F1F1F),
                width: 1.0,
              ),
            ),
          ),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: TextField(
              controller: widget.text,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
