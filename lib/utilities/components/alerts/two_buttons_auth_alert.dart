import 'package:flutter/material.dart';
import '../buttons/custom_action_button.dart';

final double alertCircularRadius = 10.0;
final double iconSize = 70.0;
final double buttonHeight = 40.0;
final double buttonWidth = 100.0;
final double buttonCircularBorderRadius = 6.0;
final double buttonFontSize = 15.0;

final Color proceedButtonColor = Color(0xFF4EABCC);
final Color proceedButtonBorderColor = Color(0xFF3492B3);
final Color cancelButtonColor = Color(0xFFF4F4F4);
final Color cancelButtonBorderColor = Color(0xFFDDDFE5);

TextStyle messageTextStyle = TextStyle(
  fontSize: 18.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

TextStyle buttonLabelTextStyle({required Color textColor}) {
  return TextStyle(
    color: textColor,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 0.5,
  );
}

void twoButtonsAuthAlert(
  BuildContext context, {
  required String message,
  required String cancelButtonText,
  required String proceedButtonText,
  VoidCallback? onCancel,
  required VoidCallback onProceed,
  IconData? icon,
  Color iconColor = Colors.blue,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(alertCircularRadius),
        ),
        title: icon != null
            ? Icon(
                icon,
                color: iconColor,
                size: iconSize,
              )
            : null,
        content: Text(
          message,
          style: messageTextStyle,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomActionButton(
                label: proceedButtonText,
                onPressed: () {
                  Navigator.pop(context);
                  onProceed();
                },
                backgroundColor: proceedButtonColor,
                borderColor: proceedButtonBorderColor,
                textColor: Colors.white,
                width: buttonWidth,
                height: buttonHeight,
                borderRadius: buttonCircularBorderRadius,
                fontSize: buttonFontSize,
              ),
              CustomActionButton(
                label: cancelButtonText,
                onPressed: () {
                  Navigator.pop(context);
                  if (onCancel != null) {
                    onCancel();
                  }
                },
                backgroundColor: cancelButtonColor,
                borderColor: cancelButtonBorderColor,
                textColor: Colors.black,
                width: buttonWidth,
                height: buttonHeight,
                borderRadius: buttonCircularBorderRadius,
                fontSize: buttonFontSize,
              ),
            ],
          ),
        ],
      );
    },
  );
}
