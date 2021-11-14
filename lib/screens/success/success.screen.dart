import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/largeButton.component.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/util/themes.util.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
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
                ),
              ),
              Column(
                children: [
                  const Text(
                    "Thank you for signing up!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Please check your email and click the Active Account button, in the email we just sent you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: "Login",
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, Screen.login, (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
