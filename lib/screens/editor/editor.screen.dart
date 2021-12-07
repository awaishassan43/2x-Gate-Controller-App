import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';

class EditorScreen extends StatefulWidget {
  final String initialValue;
  final String heading;
  final void Function(String value) onEdit;
  const EditorScreen({
    Key? key,
    required this.initialValue,
    required this.heading,
    required this.onEdit,
  }) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController controller;
  final GlobalKey<FormState> form = GlobalKey();
  String error = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  void onEditDone() {
    final String value = controller.text;

    if (value.isEmpty) {
      setState(() {
        error = "${widget.heading} cannot be empty!";
      });
    }

    widget.onEdit(value);
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
                label: widget.heading,
                controller: controller,
                autoFocus: true,
                error: error,
              ),
              const SizedBox(height: 30),
              CustomButton(text: "Save", onPressed: onEditDone),
            ],
          ),
        ),
      ),
    );
  }
}
