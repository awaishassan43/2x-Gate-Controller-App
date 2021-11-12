import 'package:flutter/material.dart';
import 'package:iot/util/themes.util.dart';

class LinkButton extends StatefulWidget {
  final void Function() onPressed;
  final String text;
  final Color color;
  const LinkButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.color = textColor,
  }) : super(key: key);

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressed = false;
          });
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: isPressed ? 0.25 : 1,
          child: Text(
            widget.text,
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
          ),
        ),
      ),
    );
  }
}
