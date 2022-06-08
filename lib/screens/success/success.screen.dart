import 'dart:async';

import 'package:app_links/app_links.dart';
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
  /// isLoading - boolean - controls the loading indicator shown the user
  bool isLoading = false;

  /// message - nullable string - controls the message that's shown to the user when the loading indicator is shown
  String? message;

  /// isEmailVerified - boolean - whether the email is verified or not, this state is updated in checkVerificationStatus
  /// and is used to enable / disable the "Continue" button
  bool isEmailVerified = false;

  /// timer - Timer - maintains the reference to a periodic timer object which runs the checkVerificationStatus
  /// every 5 seconds. This reference is then used to cancel the timer in dispose function
  late Timer timer;

  @override
  void initState() {
    super.initState();
    /**
     * Check the verification status after every 5 seconds
     */
    timer = Timer.periodic(const Duration(seconds: 5), (_) => checkVerificationStatus(context));
  }

  @override
  void dispose() {
    super.dispose();

    /**
     * Cancel the timer
     */
    timer.cancel();
  }

  /// This method is responsible for sending the verification email to the user if the user
  /// clicks the resend email button
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

  /// This method is responsible for checking the verification status of the user
  Future<void> checkVerificationStatus(BuildContext context) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);

      /**
       * Reload the latest data of the userand check whether the email is verified or not
       * if it is verified then update the state to enable the continue button
       */
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
                        onPressed: () async {
                          try {
                            final AppLinks _appLinks = AppLinks();
                            final Uri? uri = await _appLinks.getInitialAppLink();

                            if (uri != null && getContextFromDynamicLink(uri) == "/shareDevice") {
                              Navigator.pushNamedAndRemoveUntil(context, Screen.accepting, (route) => false);
                            } else {
                              Navigator.pushNamedAndRemoveUntil(context, Screen.dashboard, (route) => false);
                            }
                          } catch (e) {
                            debugPrint("Failed to get dynamic links: ${e.toString()}");
                            Navigator.pushNamedAndRemoveUntil(context, Screen.dashboard, (route) => false);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Note: Continue button will only enable if the account is verified",
                        style: TextStyle(
                          fontSize: 13,
                        ),
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
