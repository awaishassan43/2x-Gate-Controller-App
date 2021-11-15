import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final TextEditingController currentPassword;
  late final TextEditingController newPassword;
  late final TextEditingController confirmPassword;

  @override
  void initState() {
    super.initState();
    currentPassword = TextEditingController();
    newPassword = TextEditingController();
    confirmPassword = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomInput(
                    label: "Current Password",
                    icon: Icons.lock,
                    controller: currentPassword,
                    isPassword: true,
                  ),
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    color: Colors.black26,
                  ),
                  CustomInput(
                    label: "New Password",
                    icon: Icons.lock,
                    controller: newPassword,
                    isPassword: true,
                  ),
                  const SizedBox(height: 15),
                  CustomInput(
                    label: "Confirm Password",
                    icon: Icons.lock,
                    controller: confirmPassword,
                    isPassword: true,
                  ),
                ],
              ),
            ),
            CustomButton(
              text: "Save",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
