import 'dart:math';
import 'package:flutter/material.dart';
import '/util/themes.util.dart';

class CustomDropDown extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final IconData icon;

  const CustomDropDown({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: inputFieldColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.all(15),
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag,
                size: 22,
                color: Colors.black45,
              ),
              const SizedBox(width: 15),
              Text(
                text,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
          Transform.rotate(
            angle: pi / 2,
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
