import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/models/relay.model.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:iot/components/loader.component.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
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

  /// return type indicates whether the device is already connected to the required
  /// wifi or not
  Future<bool> enableWifi(BuildContext context) async {
    try {
      final PermissionStatus permission = await Location.instance.requestPermission();

      if (permission != PermissionStatus.granted) {
        throw Exception("This feature requires location permissions to determine the WiFi SSID");
      } else if (permission == PermissionStatus.deniedForever) {
        throw Exception("Please allow the location permission to the app from the app settings");
      }

      bool status = await Location.instance.serviceEnabled();

      if (!status) {
        status = await Location.instance.requestService();

        if (!status) {
          throw Exception("This feature requies the location services to be enabled");
        }
      }

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
          Connectivity().onConnectivityChanged.firstWhere((result) => result == ConnectivityStatus.wifi),
          Future.delayed(const Duration(seconds: 10), () {
            return Future.error("Timed out while trying to enable wifi");
          })
        ]);

        return await enableWifi(context);
      }

      final String? currentSSID = await WiFiForIoTPlugin.getSSID();

      if (currentSSID != null) {
        if (currentSSID == deviceSSID) {
          /// i.e. device is already connected to the required connection
          return true;
        } else {
          setState(() {
            loaderMessage = "Device seems to be connected to a different network\nPlease select the respective device from the menu below";
          });

          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendCreds() async {
    try {
      final Uri url = Uri.parse(getDeviceURL(ssid.text, password.text));
      final http.Response response = await http.post(url);
      final String deviceID = response.body;

      setState(() {
        id = deviceID;
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
        final bool isConnected = await WiFiForIoTPlugin.connect(deviceSSID, password: deviceSSID, security: NetworkSecurity.WPA);

        if (!isConnected) {
          throw Exception("Failed to connect to the device");
        }
      }

      setState(() {
        loaderMessage = "Device is connected - Sending WiFi credentials";
      });

      await sendCreds();

      if (id == null) {
        throw Exception("Failed to get response from the device");
      }

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        isLoading = false;
      });
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
      setState(() {
        isLoading = true;
        loaderMessage = "Adding device to database";
      });

      Device device = Device(
        id: id!,
        name: "Front Gate",
        temperature: 0,
        humidity: 0,
        relays: [
          Relay(id: 'r1', name: "Relay 1", isOpen: false, outputTime: 30, autoCloseTime: 30, scheduled: false, isEnabled: true),
          Relay(id: 'r2', name: "Relay 2", isOpen: false, outputTime: 30, autoCloseTime: 30, scheduled: false, isEnabled: true),
        ],
        onOpenAlert: false,
        onCloseAlert: false,
        remainedOpenAlert: null,
        nightAlert: false,
        temperatureAlert: null,
      );

      await Provider.of<DeviceController>(context, listen: false).addDevice(device, context);
      showMessage(context, "Device added successfully");

      Navigator.pop(context);
    } catch (e) {
      rethrow;
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
                      if (currentStep == 0) {
                        setState(() {
                          currentStep++;
                        });
                      } else if (currentStep == 1) {
                        await connectDevice(context);
                      } else if (currentStep == 2 && await Connectivity().checkConnection()) {
                        await addDevice(context);
                      } else {
                        showMessage(context, "Please check your internet connection");
                      }
                    } catch (e) {
                      showMessage(context, "Failed to load next step");
                    }
                  },
                  onStepCancel: () {
                    if (currentStep != 0 && currentStep != 2) {
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
                      state: currentStep > 2 ? StepState.complete : StepState.indexed,
                      isActive: currentStep == 2,
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
