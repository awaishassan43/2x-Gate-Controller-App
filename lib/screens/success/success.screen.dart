import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iot/components/link.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';
import '/components/button.component.dart';
import '/components/largeButton.component.dart';
import '/enum/route.enum.dart';
import '/util/themes.util.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool isLoading = false;
  String? message;
  bool isEmailVerified = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => checkVerificationStatus(context));
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    setState(() {
      isLoading = true;
      message = "Sending verification email";
    });

    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);
      await controller.auth.currentUser!.sendEmailVerification();

      showMessage(context, "Verification email send successfully!");
    } catch (e) {
      showMessage(context, e.toString());
    }

    setState(() {
      isLoading = false;
      message = null;
    });
  }

  Future<void> checkVerificationStatus(BuildContext context) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);

      await controller.auth.currentUser!.reload();

      if (controller.auth.currentUser!.emailVerified) {
        showMessage(context, "Email verification status complete - Email is verified");

        setState(() {
          isEmailVerified = true;
        });

        timer.cancel();
      }
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: LargeButton(
                      icon: Icons.done_rounded,
                      outerColor: Color(0xFFFDfD7C),
                      innerColor: Color(0xFFFEFE31),
                      iconColor: Color(0xFF545DCE),
                      isDisabled: false,
                    ),
                  ),
                  Column(
                    children: const [
                      Text(
                        "Thank you for signing up!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Please verify your email before you continue. Check your email and click the Active Account button, in the email we just sent you.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isEmailVerified)
                        Row(
                          children: [
                            const Text("Didn't receive the email?"),
                            const SizedBox(width: 5),
                            LinkButton(
                              onPressed: () => sendVerificationEmail(context),
                              text: "Resend",
                              color: authPrimaryTextColor,
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: "Continue",
                        isDisabled: !isEmailVerified,
                        onPressed: () {
                          Navigator.pushNamed(context, Screen.dashboard);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLoading) Loader(message: message),
          ],
        ),
      ),
    );
  }
}
