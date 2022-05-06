import 'package:flutter/material.dart';

import '../../../util/themes.util.dart';

class CustomHeading extends StatelessWidget {
  final String heading;
  const CustomHeading({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      heading,
      style: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
