import 'package:flutter/material.dart';

class CustomSelector extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  const CustomSelector({
    Key? key,
    required this.options,
    required this.selectedOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: options.asMap().entries.map<Widget>((entry) {
          final int index = entry.key;
          final String option = entry.value;

          return Column(
            children: [
              MaterialButton(
                onPressed: () {},
                height: 52.5,
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(option),
                    if (option == selectedOption)
                      const Icon(
                        Icons.done,
                        color: Colors.black87,
                      ),
                  ],
                ),
              ),
              if (index != options.length - 1)
                Container(
                  height: 0.5,
                  color: Colors.black26,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
