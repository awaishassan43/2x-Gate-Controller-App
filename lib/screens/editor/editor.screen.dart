import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';

class EditorScreen extends StatefulWidget {
  final String initialValue;
  final String heading;
  const EditorScreen({
    Key? key,
    required this.initialValue,
    required this.heading,
  }) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController controller;
  final GlobalKey<FormState> form = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.heading),
        centerTitle: true,
      ),
      body: Form(
        key: form,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInput(
                label: "",
                controller: controller,
                autoFocus: true,
              ),
              const SizedBox(height: 30),
              CustomButton(text: "Save", onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
