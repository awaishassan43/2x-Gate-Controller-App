import 'package:flutter/material.dart';
import '/components/button.component.dart';
import '/components/input.component.dart';
import '/components/link.component.dart';
import '/components/loader.component.dart';
import '/controllers/user.controller.dart';
import '/enum/route.enum.dart';
import '/screens/signup/components/dropdown.component.dart';
import '/util/constants.util.dart';
import '/util/functions.util.dart';
import '/util/themes.util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_picker/country_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  /// Value holders
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController phone;
  bool isAgreed = false;
  Country? pickedCountry;

  /// Error holders
  String emailError = '';
  String passwordError = '';
  String confirmPasswordError = '';
  String firstNameError = '';
  String lastNameError = '';
  String phoneError = '';
  String tosError = '';
  String countryError = '';
  String formError = '';

  /// Focus nodes
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  late final FocusNode confirmPasswordFocusNode;
  late final FocusNode firstNameFocusNode;
  late final FocusNode lastNameFocusNode;
  late final FocusNode phoneFocusNode;

  /// Extraneous variables
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Initializers and disposers
  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    firstName = TextEditingController();
    lastName = TextEditingController();
    phone = TextEditingController();

    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    firstName.dispose();
    lastName.dispose();
    phone.dispose();

    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    phoneFocusNode.dispose();
  }

  /// Functions
  Future<void> openTermsOfUse(BuildContext context) async {
    try {
      if (await canLaunch(linkToTermsOfUse)) {
        await launch(linkToTermsOfUse);
      }
    } catch (e) {
      showMessage(context, "Failed to open terms of use");
    }
  }

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

  bool validateFirstName() {
    if (firstName.text == "") {
      setState(() {
        firstNameError = "First name cannot be empty!";
      });

      return false;
    }

    if (firstNameError != '') {
      setState(() {
        firstNameError = '';
      });
    }

    return true;
  }

  bool validateLastName() {
    if (lastName.text == "") {
      setState(() {
        lastNameError = "First name cannot be empty!";
      });

      return false;
    }

    if (lastNameError != '') {
      setState(() {
        lastNameError = '';
      });
    }

    return true;
  }

  bool validatePassword() {
    bool checkPassed = true;
    String validationError = '';

    if (password.text == "") {
      validationError = "Password cannot be empty!";
      checkPassed = false;
    } else if (password.text.length < minCharacters) {
      validationError = "Password must be atleast $minCharacters characters in length!";
      checkPassed = false;
    } else if (!RegExp('[A-Z]').hasMatch(password.text)) {
      validationError = "Password must contain at least one capital letter";
      checkPassed = false;
    } else if (!RegExp('[a-z]').hasMatch(password.text)) {
      validationError = "Password must contain at least one small letter";
      checkPassed = false;
    } else if (!RegExp('[0-9]').hasMatch(password.text)) {
      validationError = "Password must contain at least one digit";
      checkPassed = false;
      // ignore: unnecessary_string_escapes
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password.text)) {
      validationError = "Password must contain at least one special character";
      checkPassed = false;
    }

    setState(() {
      if (checkPassed && passwordError != '') {
        passwordError = '';
      } else {
        passwordError = validationError;
      }
    });

    return checkPassed;
  }

  bool validateConfirmPassword() {
    if (confirmPassword.text == "") {
      setState(() {
        confirmPasswordError = "Password cannot be empty!";
      });

      return false;
    } else if (confirmPassword.text != password.text) {
      setState(() {
        confirmPasswordError = "Passwords must match!";
      });

      return false;
    }

    if (confirmPasswordError != '') {
      setState(() {
        confirmPasswordError = '';
      });
    }
    return true;
  }

  bool validateTOS() {
    if (!isAgreed) {
      setState(() {
        tosError = "You need to agree to Terms of Service to continue";
      });

      return false;
    }

    if (tosError != '') {
      setState(() {
        tosError = '';
      });
    }

    return true;
  }

  bool validatePhone() {
    if (phone.text == '') {
      setState(() {
        phoneError = "Phone number must not be empty!";
      });

      return false;
    } else if (int.tryParse(phone.text) == null) {
      setState(() {
        phoneError = "Phone number must be valid!";
      });

      return false;
    }

    if (phoneError != '') {
      setState(() {
        phoneError = '';
      });
    }

    return true;
  }

  bool validateCountry() {
    if (pickedCountry == null) {
      setState(() {
        countryError = "Please select a country!";
      });

      return false;
    }

    if (countryError != '') {
      setState(() {
        countryError = '';
      });
    }

    return true;
  }

  void showCountryPickerDialog(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        setState(() {
          pickedCountry = country;
        });

        FocusScope.of(context).requestFocus(phoneFocusNode);
      },
    );
  }

  Future<void> signup(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        debugPrint("Form is invalid");
        return;
      }

      final bool isEmailValid = validateEmail();
      final bool isPasswordValid = validatePassword();
      final bool isConfirmPasswordValid = validateConfirmPassword();
      final bool isFirstNameValid = validateFirstName();
      final bool isLastNameValid = validateLastName();
      final bool isPhoneValid = validatePhone();
      final bool isCountryValid = validateCountry();
      final bool isTOSAgreed = validateTOS();

      if (!isEmailValid ||
          !isFirstNameValid ||
          !isLastNameValid ||
          !isPhoneValid ||
          !isCountryValid ||
          !isPasswordValid ||
          !isConfirmPasswordValid ||
          !isTOSAgreed) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      FocusScope.of(context).unfocus();

      await Provider.of<UserController>(context, listen: false).register(
        email.text.trim(),
        password.text,
        firstName.text.trim(),
        lastName.text.trim(),
        pickedCountry!.phoneCode,
        phone.text.trim(),
      );

      showMessage(context, "Account created successfully!");
      Navigator.pushNamedAndRemoveUntil(context, Screen.success, (route) => false);
    } catch (e) {
      showMessage(context, "Failed to create the account");
      setState(() {
        isLoading = false;
        formError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                              'Create An Account',
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
                              icon: Icons.email,
                              label: "Email Address *",
                              controller: email,
                              error: emailError,
                              autoFocus: true,
                              textInputType: TextInputType.emailAddress,
                              focusNode: emailFocusNode,
                              nextFocusNode: passwordFocusNode,
                            ),
                            const SizedBox(height: 12.5),
                            CustomInput(
                              icon: Icons.lock,
                              label: "Password *",
                              isPassword: true,
                              controller: password,
                              error: passwordError,
                              textInputType: TextInputType.visiblePassword,
                              focusNode: passwordFocusNode,
                              nextFocusNode: confirmPasswordFocusNode,
                            ),
                            const SizedBox(height: 12.5),
                            CustomInput(
                              icon: Icons.lock,
                              label: "Confirm Password *",
                              isPassword: true,
                              controller: confirmPassword,
                              textInputType: TextInputType.visiblePassword,
                              error: confirmPasswordError,
                              focusNode: confirmPasswordFocusNode,
                              nextFocusNode: firstNameFocusNode,
                            ),
                            const SizedBox(height: 12.5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: CustomInput(
                                    icon: Icons.person,
                                    label: "First Name *",
                                    controller: firstName,
                                    error: firstNameError,
                                    focusNode: firstNameFocusNode,
                                    nextFocusNode: lastNameFocusNode,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: CustomInput(
                                    icon: Icons.person,
                                    label: "Last Name *",
                                    controller: lastName,
                                    error: lastNameError,
                                    focusNode: lastNameFocusNode,
                                    onDone: () => showCountryPickerDialog(context),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 0.5,
                              color: textColor.withOpacity(0.5),
                              margin: const EdgeInsets.symmetric(vertical: 12.5),
                            ),
                            Column(
                              children: [
                                CustomDropDown(
                                  onPressed: () => showCountryPickerDialog(context),
                                  icon: Icons.flag,
                                  text: pickedCountry == null ? "Country *" : pickedCountry!.displayNameNoCountryCode,
                                ),
                                if (countryError != '')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.5),
                                    child: Text(
                                      countryError,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12.5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropDown(
                                  onPressed: () {
                                    showCountryPicker(
                                      context: context,
                                      onSelect: (country) {
                                        pickedCountry = country;
                                      },
                                    );
                                  },
                                  text: pickedCountry == null ? '-' : pickedCountry!.phoneCode,
                                  icon: Icons.flag,
                                ),
                                const SizedBox(width: 12.5),
                                Expanded(
                                  child: CustomInput(
                                    label: "Phone number",
                                    controller: phone,
                                    error: phoneError,
                                    textInputType: TextInputType.phone,
                                    focusNode: phoneFocusNode,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                            if (tosError != '')
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Text(
                                  tosError,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
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
                              onPressed: () {
                                signup(context);
                              },
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
                              Navigator.pushNamedAndRemoveUntil(context, Screen.login, (route) => false);
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
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
