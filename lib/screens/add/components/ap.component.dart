import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';

import '../../../components/input.component.dart';

class AccessPointComponent extends StatefulWidget {
  final String ssid;
  final void Function(String ssid, String password) onPressed;
  const AccessPointComponent({
    Key? key,
    required this.ssid,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<AccessPointComponent> createState() => _AccessPointComponentState();
}

class _AccessPointComponentState extends State<AccessPointComponent> {
  bool isExpanded = false;

  // Field and errors
  late final TextEditingController password;
  String passwordError = '';

  @override
  void initState() {
    super.initState();
    password = TextEditingController();
  }

  void connect() {
    final String value = password.text;

    if (value.isEmpty) {
      setState(() {
        passwordError = "Password must not be empty";
      });

      return;
    } else if (passwordError.isNotEmpty) {
      setState(() {
        passwordError = '';
      });

      return;
    }

    widget.onPressed(widget.ssid, value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: MaterialButton(
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.hardEdge,
        onPressed: () {
          if (!isExpanded) {
            setState(() {
              isExpanded = true;
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.ssid,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              CustomInput(
                controller: password,
                autoFocus: true,
                isPassword: true,
                label: "WiFi Password",
                error: passwordError,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    padding: 10,
                    text: "Cancel",
                    onPressed: () {
                      setState(() {
                        isExpanded = false;
                      });
                    },
                  ),
                  const SizedBox(width: 5),
                  CustomButton(
                    padding: 10,
                    text: "Connect",
                    onPressed: connect,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
