import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/link.component.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/screens/signup/components/dropdown.component.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:iot/util/themes.util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_picker/country_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController phone;
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
    confirmPassword = TextEditingController();
    firstName = TextEditingController();
    lastName = TextEditingController();
    phone = TextEditingController();
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
                          'Create An Account',
                          style: Theme.of(context).textTheme.headline5?.copyWith(
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 20),
                        CustomInput(icon: Icons.email, label: "Email Address *", controller: email),
                        const SizedBox(height: 12.5),
                        CustomInput(icon: Icons.lock, label: "Password *", isPassword: true, controller: password),
                        const SizedBox(height: 12.5),
                        CustomInput(icon: Icons.lock, label: "Confirm Password *", isPassword: true, controller: confirmPassword),
                        const SizedBox(height: 12.5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: CustomInput(icon: Icons.person, label: "First Name *", controller: firstName),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: CustomInput(icon: Icons.person, label: "Last Name *", controller: lastName),
                            ),
                          ],
                        ),
                        Container(
                          height: 0.5,
                          color: textColor.withOpacity(0.5),
                          margin: const EdgeInsets.symmetric(vertical: 12.5),
                        ),
                        CustomDropDown(
                          onPressed: () {
                            showCountryPicker(context: context, showPhoneCode: true, onSelect: (country) {});
                          },
                          icon: Icons.flag,
                          text: "Country *",
                        ),
                        const SizedBox(height: 12.5),
                        Row(
                          children: [
                            CustomDropDown(
                              onPressed: () {
                                showCountryPicker(context: context, onSelect: (country) {});
                              },
                              text: "+1",
                              icon: Icons.flag,
                            ),
                            const SizedBox(width: 12.5),
                            Expanded(
                              child: CustomInput(label: "Phone number", controller: phone),
                            ),
                          ],
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
                              const Text("By Registering, I agree to "),
                              LinkButton(
                                onPressed: () {
                                  openTermsOfUse(context);
                                },
                                text: "Terms of Use.",
                                color: authPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          text: "Register",
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  /**
                   * End of form section
                   */

                  const SizedBox(height: 50),

                  /**
                   * Bottom Section
                   */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      LinkButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(Screen.login);
                        },
                        text: "Login",
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  /**
                   * End of bottom section
                   */
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
