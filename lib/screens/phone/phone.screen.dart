import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/screens/signup/components/dropdown.component.dart';

class PhoneEditingScreen extends StatefulWidget {
  final String code;
  final String phone;
  const PhoneEditingScreen({
    Key? key,
    required this.code,
    required this.phone,
  }) : super(key: key);

  @override
  _PhoneEditingScreenState createState() => _PhoneEditingScreenState();
}

class _PhoneEditingScreenState extends State<PhoneEditingScreen> {
  bool isLoading = false;
  late Country? pickedCountry;
  late final TextEditingController controller;

  String countryError = '';
  String phoneError = '';

  @override
  void initState() {
    controller = TextEditingController(text: widget.phone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Column(
            children: [
              CustomDropDown(
                onPressed: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (country) {
                      setState(() {
                        pickedCountry = country;
                      });
                    },
                  );
                },
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
                  controller: controller,
                  error: phoneError,
                  onDone: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
