import 'package:flutter/material.dart';
import '/components/button.component.dart';
import '/components/input.component.dart';
import '/components/loader.component.dart';
import '/controllers/user.controller.dart';
import '/util/functions.util.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isLoading = false;

  late final TextEditingController currentPassword;
  late final TextEditingController newPassword;
  late final TextEditingController confirmPassword;
  late final UserController controller;

  String formError = '';
  String currentPassError = '';
  String newPassError = '';
  String confirmPassError = '';

  @override
  void initState() {
    super.initState();
    currentPassword = TextEditingController();
    newPassword = TextEditingController();
    confirmPassword = TextEditingController();

    controller = Provider.of<UserController>(context, listen: false);
  }

  bool validateCurrentPassword() {
    if (currentPassword.text == "") {
      setState(() {
        currentPassError = "This field cannot be empty!";
      });

      return false;
    }

    if (currentPassError != '') {
      setState(() {
        currentPassError = '';
      });
    }
    return true;
  }

  bool validateNewPassword() {
    if (newPassword.text == "") {
      setState(() {
        newPassError = "This field cannot be empty!";
      });

      return false;
    } else if (newPassword.text.length < 6) {
      setState(() {
        newPassError = "Password must be atleast 6 characters in length!";
      });

      return false;
    }

    if (newPassError != '') {
      setState(() {
        newPassError = '';
      });
    }
    return true;
  }

  bool validateConfirmPassword() {
    if (confirmPassword.text == "") {
      setState(() {
        confirmPassError = "This field cannot be empty!";
      });

      return false;
    } else if (confirmPassword.text != newPassword.text) {
      setState(() {
        confirmPassError = "Passwords must match!";
      });

      return false;
    }

    if (confirmPassError != '') {
      setState(() {
        confirmPassError = '';
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
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
                        label: "Current Password",
                        icon: Icons.lock,
                        error: currentPassError,
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
                        error: newPassError,
                      ),
                      const SizedBox(height: 15),
                      CustomInput(
                        label: "Confirm Password",
                        icon: Icons.lock,
                        controller: confirmPassword,
                        isPassword: true,
                        error: confirmPassError,
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
                  text: "Update Password",
                  onPressed: () async {
                    final bool iscurrentPasswordValid = validateCurrentPassword();
                    final bool isNewPasswordValid = validateNewPassword();
                    final bool isConfirmPasswordValid = validateConfirmPassword();

                    if (!iscurrentPasswordValid || !isNewPasswordValid || !isConfirmPasswordValid) {
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      await controller.updatePassword(currentPassword.text, newPassword.text);

                      showMessage(context, "Password updated successfully!");
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        formError = e.toString();
                        isLoading = false;
                      });

                      showMessage(context, "Failed to update the password");
                    }
                  },
                ),
              ],
            ),
          ),
          if (isLoading) const Loader(message: "Updating password"),
        ],
      ),
    );
  }
}
