import 'package:flutter/material.dart';
import '/components/button.component.dart';
import '/components/input.component.dart';
import '/components/loader.component.dart';
import '/util/functions.util.dart';
import 'package:provider/provider.dart';
import '/controllers/device.controller.dart';

class EditorScreen extends StatefulWidget {
  final String initialValue;
  final String title;
  final IconData icon;
  final bool isEditingDevice;
  final Future<void> Function(String value, BuildContext context) onSubmit;
  const EditorScreen({
    Key? key,
    required this.initialValue,
    required this.onSubmit,
    required this.title,
    required this.icon,
    this.isEditingDevice = true,
  }) : super(key: key);

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  bool isLoading = false;

  late final TextEditingController textController;
  late final DeviceController controller;

  String formError = '';
  String fieldError = '';

  @override
  void initState() {
    super.initState();
    controller = Provider.of<DeviceController>(context, listen: false);
    textController = TextEditingController(text: widget.initialValue);
  }

  bool validateName() {
    if (textController.text == "") {
      setState(() {
        fieldError = "This field cannot be empty!";
      });

      return false;
    }

    if (fieldError != '') {
      setState(() {
        fieldError = '';
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomInput(
                        label: widget.title,
                        icon: widget.icon,
                        error: fieldError,
                        controller: textController,
                      ),
                      if (formError != '')
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            formError,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                CustomButton(
                  text: "Update ${widget.isEditingDevice ? "device" : "profile"}",
                  onPressed: () async {
                    final bool isNameValid = validateName();

                    if (!isNameValid) {
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      await widget.onSubmit(textController.text.trim(), context);

                      showMessage(context, "${widget.isEditingDevice ? "Device" : "Profile"} updated successfully!");
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        formError = e.toString();
                        isLoading = false;
                      });

                      textController.text = widget.initialValue;
                      showMessage(context, "Failed to update the ${widget.isEditingDevice ? "Device" : "Profile"}");
                    }
                  },
                ),
              ],
            ),
          ),
          if (isLoading) Loader(message: "Updating ${widget.isEditingDevice ? "Device" : "Profile"}"),
        ],
      ),
    );
  }
}
