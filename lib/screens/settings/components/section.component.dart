import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final String header;
  final List<Widget> children;
  const Section({
    Key? key,
    required this.header,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 7.5),
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
