import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/profile.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

class UpdateNameScreen extends StatefulWidget {
  const UpdateNameScreen({Key? key}) : super(key: key);

  @override
  State<UpdateNameScreen> createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  bool isLoading = false;

  late final TextEditingController name;
  late final UserController controller;
  late Profile profile;

  String formError = '';
  String nameError = '';

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    controller = Provider.of<UserController>(context, listen: false);
    profile = controller.profile!;
  }

  bool validateName() {
    if (name.text == "") {
      setState(() {
        nameError = "This field cannot be empty!";
      });

      return false;
    }

    if (nameError != '') {
      setState(() {
        nameError = '';
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update name"),
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
                        label: "Name of the user",
                        icon: Icons.person,
                        error: nameError,
                        controller: name,
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
                  text: "Update name",
                  onPressed: () async {
                    final bool isNameValid = validateName();

                    if (!isNameValid) {
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    final String previousName = profile.name;

                    try {
                      controller.profile!.name = name.text.trim();
                      await controller.updateProfile();

                      showMessage(context, "Name updated successfully!");
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        formError = e.toString();
                        isLoading = false;
                      });

                      controller.profile!.name = previousName;
                      showMessage(context, "Failed to update the name");
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
