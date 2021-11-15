import 'package:flutter/material.dart';

class BottomSectionItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function()? onPressed;
  const BottomSectionItem({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color color = Colors.black45;

    return MaterialButton(
      onPressed: onPressed,
      elevation: 0,
      highlightElevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      disabledElevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 2.5),
          Text(
            text,
            style: const TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
