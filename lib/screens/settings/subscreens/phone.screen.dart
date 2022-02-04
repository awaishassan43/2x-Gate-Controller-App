import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '/components/button.component.dart';
import '/components/input.component.dart';
import '/components/loader.component.dart';
import '/controllers/user.controller.dart';
import '/models/profile.model.dart';
import '/screens/signup/components/dropdown.component.dart';
import '/util/functions.util.dart';
import 'package:provider/provider.dart';

class PhoneEditingScreen extends StatefulWidget {
  const PhoneEditingScreen({Key? key}) : super(key: key);

  @override
  _PhoneEditingScreenState createState() => _PhoneEditingScreenState();
}

class _PhoneEditingScreenState extends State<PhoneEditingScreen> {
  bool isLoading = false;
  late String code;
  late final TextEditingController phone;
  late final UserController userController;
  late final Profile profile;

  String error = '';

  @override
  void initState() {
    userController = Provider.of<UserController>(context, listen: false);
    profile = userController.profile!;

    phone = TextEditingController(text: profile.phone);
    code = profile.code;
    super.initState();
  }

  bool validatePhone() {
    if (phone.text == '') {
      setState(() {
        error = "Phone number must not be empty!";
      });

      return false;
    } else if (int.tryParse(phone.text) == null) {
      setState(() {
        error = "Phone number must be valid!";
      });

      return false;
    }

    if (error != '') {
      setState(() {
        error = '';
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone"),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDropDown(
                        onPressed: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (country) {
                              if (country.phoneCode != code) {
                                setState(() {
                                  code = country.phoneCode;
                                });
                              }
                            },
                          );
                        },
                        text: code,
                        icon: Icons.flag,
                      ),
                      const SizedBox(width: 12.5),
                      Expanded(
                        child: CustomInput(
                          label: "Phone number",
                          controller: phone,
                          error: error,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: "Update phone",
                  onPressed: () async {
                    final bool isPhoneValid = validatePhone();

                    if (!isPhoneValid) {
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    final String previousCode = profile.code;
                    final String previousPhone = profile.phone;
                    try {
                      if (previousCode != code || previousPhone != phone.text.trim()) {
                        userController.profile!.code = code;
                        userController.profile!.phone = phone.text.trim();

                        await userController.updateProfile();
                      }

                      showMessage(context, "Profile updated successfully!");
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });

                      userController.profile!.code = previousCode;
                      userController.profile!.phone = previousPhone;
                      showMessage(context, e.toString());
                    }
                  },
                ),
              ],
            ),
          ),
          if (isLoading) const Loader(message: "Updating phone number"),
        ],
      ),
    );
  }
}
