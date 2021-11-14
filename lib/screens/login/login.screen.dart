import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/link.component.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:iot/util/themes.util.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController email;
  late TextEditingController password;
  bool isAgreed = false;

  final GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  Future<void> openTermsOfUse(BuildContext context) async {
    try {
      if (await canLaunch(linkToTermsOfUse)) {
        await launch(linkToTermsOfUse);
      }
    } catch (e) {
      showMessage(context, "Failed to open terms of use");
    }
  }

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 100,
                  ),

                  /**
                   * Top Section
                   */
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 120,
                      maxWidth: 120,
                    ),
                    child: Image.asset(
                      'assets/icons/a.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  /**
                   * End of top section
                   */

                  const SizedBox(
                    height: 75,
                  ),

                  /**
                   * Form Section
                   */
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.headline5?.copyWith(
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 20),
                        CustomInput(
                          icon: Icons.person,
                          label: "Email Address",
                          controller: email,
                        ),
                        const SizedBox(height: 12.5),
                        CustomInput(
                          icon: Icons.lock,
                          label: "Password",
                          isPassword: true,
                          controller: password,
                        ),
                        const SizedBox(height: 12.5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: LinkButton(
                            onPressed: () {},
                            text: "Forgot Password?",
                          ),
                        ),
                        const SizedBox(height: 50),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAgreed = !isAgreed;
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: isAgreed,
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    isAgreed = value;
                                  });
                                },
                              ),
                              const Text("By Signing in, I agree to "),
                              LinkButton(
                                onPressed: () {
                                  openTermsOfUse(context);
                                },
                                text: "Terms of Use",
                                color: authPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          text: "Login",
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context, Screen.dashboard, (route) => false);
                          },
                        ),
                      ],
                    ),
                  ),
                  /**
                   * End of form section
                   */
                ],
              ),
            ),
          ),

          /**
           * Bottom Section
           */
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Don't have an account?",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                CustomButton(
                  text: "Create an Account",
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(Screen.signup);
                  },
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
          /**
           * End of bottom section
           */
        ],
      ),
    );
  }
}
