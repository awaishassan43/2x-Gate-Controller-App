import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:iot/components/loader.component.dart';
import 'package:http/http.dart' as http;

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
  bool isLoading = false;
  String? mac;
  String? loaderMessage;
  String formError = '';

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

  bool validateField(TextEditingController field) {
    if (field.text.isEmpty) {
      return false;
    }

    return true;
  }

  /// return type indicates whether the device is already connected to the required
  /// wifi or not
  Future<bool> enableWifi(BuildContext context) async {
    try {
      final bool isWiFiEnabled = await WiFiForIoTPlugin.isEnabled();

      if (!isWiFiEnabled) {
        setState(() {
          loaderMessage = "Seems like wifi is not enabled!";
        });

        await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);

        setState(() {
          loaderMessage = "Waiting for wifi status to change to enabled";
        });

        await Future.any([
          Connectivity().onConnectivityChanged.firstWhere((result) => result == ConnectivityResult.wifi),
          Future.delayed(const Duration(seconds: 10), () {
            return Future.error("Timed out while trying to enable wifi");
          })
        ]);

        return await enableWifi(context);
      }

      setState(() {
        loaderMessage = "Getting the SSID of the connected WiFi";
      });

      final String? currentSSID = await WiFiForIoTPlugin.getSSID();

      if (currentSSID != null && currentSSID == deviceSSID) {
        /// i.e. device is already connected to the required connection
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendCreds() async {
    try {
      final Uri url = Uri.parse(deviceURL);
      final http.Response response = await http.post(url);
      final String macAddress = response.body;

      setState(() {
        mac = macAddress;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> connectDevice(BuildContext context) async {
    try {
      setState(() {
        formError = '';
      });

      validateSSID();
      validatePassword();

      if (ssidError.isNotEmpty || passwordError.isNotEmpty) {
        throw Exception("Cannot connect the device");
      }

      FocusScope.of(context).unfocus();

      setState(() {
        isLoading = true;
        loaderMessage = "Checking wifi status";
      });

      final bool isAlreadyConnected = await enableWifi(context);

      if (!isAlreadyConnected) {
        setState(() {
          loaderMessage = "Unable to determine the SSID\nPlease select the device's WiFi from the menu presented";
        });

        final bool isConnected = await WiFiForIoTPlugin.connect(deviceSSID, password: deviceSSID, security: NetworkSecurity.WPA);

        if (!isConnected) {
          throw Exception("Failed to connect to the device");
        }
      }

      setState(() {
        loaderMessage = "Device is connected - Sending WiFi credentials";
      });

      await sendCreds();

      if (mac != null) {
        await Future.delayed(const Duration(seconds: 2));

        showMessage(context, "Device added successfully");
        Navigator.pop(context);
      } else {
        throw Exception("Failed to get response from the device");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loaderMessage = null;
        formError = e.toString();
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter the WiFi credentials",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const Text("Please enter the credentials for the WiFi with which your IoT device will connect"),
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
                const SizedBox(height: 30),
                const Text(
                  "* Before proceeding, please make sure that your device is in access mode. Once you are done, proceed by clicking the button.",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: "Connect",
                    onPressed: () {
                      connectDevice(context);
                    },
                  ),
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
