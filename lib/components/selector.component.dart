import 'package:flutter/material.dart';

class CustomSelector<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final void Function(T? value) onSelected;
  final String Function(T value)? transformer;
  final String? nullText;
  final T? nullValue;

  const CustomSelector({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    this.transformer,
    this.nullText,
    this.nullValue,
  })  : assert(
          (nullText != null && nullValue != null) || (nullText == null && nullValue == null),
          "Either provide both values or remove both values",
        ),
        super(key: key);

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
        children: items.asMap().entries.map<Widget>(
          (entry) {
            final int index = entry.key;
            final String option = transformer != null ? transformer!(entry.value) : entry.value.toString();

            print(nullText);
            print(nullValue);
            print(entry.value);
            return Column(
              children: [
                MaterialButton(
                  onPressed: () {
                    onSelected(entry.value);
                  },
                  height: 52.5,
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option == null.toString()
                            ? "None"
                            : nullValue != null && nullValue == entry.value
                                ? nullText!
                                : option,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (entry.value == selectedItem)
                        const Icon(
                          Icons.done,
                          color: Colors.black87,
                        ),
                    ],
                  ),
                ),
                if (index != items.length - 1)
                  Container(
                    height: 0.5,
                    color: Colors.black26,
                  ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}
