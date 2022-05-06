import 'package:flutter/material.dart';

import 'heading.component.dart';
import '../../../util/functions.util.dart';

class DaySelector extends StatelessWidget {
  final String day;
  final void Function(String day, bool isSelected) onSelected;
  final bool isSelected;
  const DaySelector({
    Key? key,
    required this.day,
    required this.onSelected,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onSelected(day, isSelected),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomHeading(heading: day.capitalize()),
          if (isSelected) const Icon(Icons.done, color: Colors.green),
        ],
      ),
    );
  }
}
