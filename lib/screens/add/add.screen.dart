import 'dart:async';
import 'package:flutter/material.dart';
import '/components/input.component.dart';
import '/controllers/device.controller.dart';
import '/util/functions.util.dart';
import 'package:provider/provider.dart';
import '/components/loader.component.dart';
import 'package:http/http.dart' as http;
import 'package:cross_connectivity/cross_connectivity.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  late final PageController controller;
  late final TextEditingController ssid;
  late final TextEditingController password;

  String ssidError = '';
  String passwordError = '';
  String formError = '';
  String addError = '';

  bool isLoading = false;

  String? id;
  String? loaderMessage;

  int currentStep = 0;
  final int totalSteps = 3;

  @override
  void initState() {
    super.initState();

    controller = PageController();
    ssid = TextEditingController();
    password = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void validateSSID() {
    setState(() {
      if (ssid.text.isEmpty) {
        ssidError = "SSID cannot be empty!";
      } else if (ssidError.isNotEmpty) {
        ssidError = '';
      }
    });
  }

  void validatePassword() {
    setState(() {
      if (password.text.isEmpty) {
        passwordError = "Password cannot be empty!";
      } else if (passwordError.isNotEmpty) {
        passwordError = '';
      }
    });
  }

  Future<void> sendCreds() async {
    try {} catch (e) {
      rethrow;
    }
  }

  Future<void> connectDevice(BuildContext context) async {
    try {
      // Resetting the form error state
      if (formError != '') {
        setState(() {
          formError = '';
        });
      }

      // validating the fields
      validateSSID();
      validatePassword();

      // In case of an error, show error (error is handled in the respective functions above)
      if (ssidError.isNotEmpty || passwordError.isNotEmpty) {
        return;
      }

      // Get rid of the keyboard
      if (FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
      }

      setState(() {
        isLoading = true;
        loaderMessage = "Sending WiFi credentials to the device";
      });

      // Send the request to the device to get the device id
      final Uri url = Uri.parse(getDeviceURL(ssid.text, password.text));
      final http.Response response = await http.post(url).timeout(
        const Duration(milliseconds: 7500),
        onTimeout: () {
          throw "Timed out while trying to send credentials to the device";
        },
      );

      // Check if the device id was received successfully, and in case of success update the state
      final String? deviceID = response.body;
      if (deviceID == null) {
        throw Exception("Failed to get response from the device");
      }

      setState(() {
        isLoading = false;
        id = deviceID;
        currentStep++;
      });

      showMessage(context, "Successfully updated credentials on device!");
    } catch (e) {
      setState(() {
        isLoading = false;
        loaderMessage = null;
        formError = e.toString();
      });
    }
  }

  Future<void> addDevice(BuildContext context) async {
    try {
      if (id == null) {
        throw "Device id is null!";
      }

      // Reset the error state and show the loading indicator
      setState(() {
        if (addError != '') {
          addError = '';
        }

        isLoading = true;
        loaderMessage = "Adding device to database";
      });

      // Add the device to the database
      final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
      await controller.addDevice(id!, context);
      showMessage(context, "Device added successfully");

      // Go to previous screen
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
        loaderMessage = null;
        addError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Device"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stepper(
                  onStepContinue: () async {
                    try {
                      if (currentStep == 0 || currentStep == 1) {
                        setState(() {
                          currentStep++;
                        });
                      } else if (currentStep == 2) {
                        await connectDevice(context);
                      } else if (currentStep == 3 && await Connectivity().checkConnection()) {
                        await addDevice(context);
                      } else {
                        showMessage(context, "Please check your internet connection");
                      }
                    } catch (e) {
                      showMessage(context, "Failed to load next step");
                    }
                  },
                  onStepCancel: () {
                    if (currentStep != 0 && currentStep != 3) {
                      setState(() {
                        currentStep--;
                      });
                    }
                  },
                  steps: [
                    Step(
                      state: currentStep > 0 ? StepState.complete : StepState.indexed,
                      isActive: currentStep == 0,
                      title: const Text(
                        "Set the device to access mode",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        "Before proceeding, please make sure that the device is in access mode",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Step(
                      state: currentStep > 1 ? StepState.complete : StepState.indexed,
                      isActive: currentStep == 1,
                      title: const Text(
                        "Connect to your device's WiFi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        "Before proceeding, please make sure that your mobile is connected to the WiFi of the device",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Step(
                      state: currentStep > 2 ? StepState.complete : StepState.indexed,
                      isActive: currentStep == 2,
                      title: const Text(
                        "Enter the WiFi credentials",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        children: [
                          const Text(
                            "Please enter the credentials for the WiFi with which your IoT device will connect",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 15),
                          Form(
                            child: Column(
                              children: [
                                if (formError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10,
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: Text(
                                      formError,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                CustomInput(
                                  icon: Icons.network_wifi_rounded,
                                  label: "WiFi SSID",
                                  controller: ssid,
                                  error: ssidError,
                                ),
                                const SizedBox(height: 12.5),
                                CustomInput(
                                  icon: Icons.wifi_lock_rounded,
                                  label: "WiFi Password",
                                  controller: password,
                                  isPassword: true,
                                  error: passwordError,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      // state: currentStep > 3 ? StepState.complete : StepState.indexed,
                      isActive: currentStep == 3,
                      title: const Text(
                        "Reconnect to internet",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        children: [
                          const Text(
                            "Reconnect your device to internet to continue",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 15),
                          if (addError.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                                left: 20,
                                right: 20,
                              ),
                              child: Text(
                                addError,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ConnectivityBuilder(
                            builder: (context, isConnected, _) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    isConnected == true ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off,
                                    color: isConnected == true ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isConnected == true ? "Connected to internet" : "Disconnected from internet",
                                    style: TextStyle(
                                      color: isConnected == true ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  currentStep: currentStep,
                ),
              ],
            ),
          ),
          if (isLoading) Loader(message: loaderMessage),
        ],
      ),
    );
  }
}
