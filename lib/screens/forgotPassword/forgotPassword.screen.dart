import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/link.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

class CustomScreen extends StatefulWidget {
  const CustomScreen({Key? key}) : super(key: key);

  @override
  _CustomScreenState createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  /// Value holders
  late TextEditingController email;
  bool isLoading = false;

  /// Error holders
  String emailError = '';
  String formError = '';

  /// Extraneous variables
  final GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  /// initializers and disposers
  @override
  void initState() {
    super.initState();
    email = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    email.dispose();
  }

  /// Functions
  bool validateEmail() {
    if (email.text == "") {
      setState(() {
        emailError = "Email cannot be empty!";
      });

      return false;
    }

    if (emailError != '') {
      setState(() {
        emailError = '';
      });
    }

    return true;
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    try {
      final isEmailValid = validateEmail();

      if (!isEmailValid) {
        return;
      }

      final UserController controller = Provider.of<UserController>(context, listen: false);
      controller.forgotPassword(email.text);

      showMessage(context, "Email sent successfully! Please check your email for further instructions");
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

  /// Build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                      'assets/icons/logo.png',
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
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Forgot Password',
                          style: Theme.of(context).textTheme.headline5?.copyWith(
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 20),
                        if (formError != '')
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              formError,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        CustomInput(
                          icon: Icons.person,
                          error: emailError,
                          label: "Email Address",
                          controller: email,
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: "Reset Password",
                          onPressed: () => sendVerificationEmail(context),
                        ),
                      ],
                    ),
                  ),
                  /**
                   * End of form section
                   */

                  /**
                   * Bottom Section
                   */
                  const SizedBox(height: 12.5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: LinkButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Screen.forgotPassword);
                      },
                      text: "Forgot Password?",
                    ),
                  ),
                  /**
                   * End of bottom section
                   */
                ],
              ),
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
