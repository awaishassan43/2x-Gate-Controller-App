import 'dart:async';

import 'package:flutter/material.dart';
import '/util/themes.util.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final void Function() onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool disableElevation;
  final double borderRadius;
  final double padding;
  final bool isDisabled;
  final bool withOpacityAnimation;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = authPrimaryColor,
    this.textColor = Colors.black,
    this.disableElevation = false,
    this.borderRadius = 5,
    this.padding = 15.0,
    this.isDisabled = false,
    this.withOpacityAnimation = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      onPressed: widget.isDisabled
          ? null
          : () {
              widget.onPressed();

              if (widget.withOpacityAnimation) {
                setState(() {
                  isPressed = true;
                });

                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    isPressed = false;
                  });
                });
              }
            },
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.isDisabled ? Colors.white60 : widget.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      disabledColor: Colors.grey.withOpacity(0.4),
      padding: EdgeInsets.all(widget.padding),
      splashColor: null,
      color: isPressed ? widget.backgroundColor.withOpacity(0.5) : widget.backgroundColor,
      elevation: widget.disableElevation ? 0 : 2,
      highlightElevation: widget.disableElevation ? 0 : 8,
    );
  }
}
