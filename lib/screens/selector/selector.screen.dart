import 'package:flutter/material.dart';
import 'package:iot/screens/selector/components/selector.component.dart';

class SelectorScreen extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  const SelectorScreen({
    Key? key,
    required this.title,
    required this.options,
    required this.selectedOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomSelector(
          options: options,
          selectedOption: selectedOption,
        ),
      ),
    );
  }
}
