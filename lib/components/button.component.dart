import 'package:flutter/material.dart';
import 'package:iot/util/themes.util.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool disableElevation;
  final double borderRadius;
  final double padding;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = authPrimaryColor,
    this.textColor = Colors.black,
    this.disableElevation = false,
    this.borderRadius = 5,
    this.padding = 15.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsets.all(padding),
      color: backgroundColor,
      elevation: disableElevation ? 0 : 2,
      highlightElevation: disableElevation ? 0 : 8,
    );
  }
}
