import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final String? header;
  final String? subHeader;
  final List<Widget> children;
  const Section({
    Key? key,
    this.header,
    this.subHeader,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (header != null)
                Text(
                  header!,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              if (header != null && subHeader != null) const SizedBox(width: 7.5),
              if (subHeader != null)
                Text(
                  subHeader!,
                  style: const TextStyle(
                    color: Colors.black26,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 7.5),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
