import 'package:flutter/material.dart';

class Seperator extends StatelessWidget {
  final bool isVerticalSeperator;
  final double seperatorWidth;
  const Seperator({
    Key? key,
    this.isVerticalSeperator = true,
    this.seperatorWidth = 1.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: isVerticalSeperator ? SizedBox(width: seperatorWidth) : SizedBox(height: seperatorWidth));
  }
}
