import 'dart:async';
import 'dart:io';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:iot/util/constants.util.dart';
import 'package:provider/provider.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../components/loader.component.dart';
import '../../controllers/device.controller.dart';
import '../../util/functions.util.dart';
import 'components/ap.component.dart';

class AddDeviceScreen extends StatefulWidget {
  final bool changeCredentialsOnly;
  const AddDeviceScreen({
    Key? key,
    this.changeCredentialsOnly = false,
  }) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  /// Process state
  bool isLoading = true;
  String? loaderMessage = "Waiting for the controller to be connected";
  ConnectivityStatus status = ConnectivityStatus.none;
  String? initialSSID;

  // true means no need to rerun the prepare function
  bool initialSetupDone = false;

  // true means credentials have been sent... so no need to run
  bool credentialsSent = false;
  bool internetReconnected = false;
  String? deviceID;
  bool deviceRegistered = false;

  /// SSID and password state
  String? selectedSSID;
  String? selectedPassword;

  /// Errors
  String? addError = '';

  @override
  void initState() {
    super.initState();
    prepare(context);
  }

  Future<void> prepare(BuildContext context) async {
    try {
      if (addError != null) {
        setState(() {
          addError = null;
        });
      }

      // Verifying that the permissions are granted and check the initial connection type
      final ConnectivityStatus connectionType = await verifySetup();

      if (connectionType != ConnectivityStatus.none) {
        // In case if the connection type is wifi... then get ssid and set the value
        if (connectionType != ConnectivityStatus.wifi) {
          final String? connectedSSID = await getConnectedWiFi();

          if (connectedSSID != null) {
            setState(() {
              initialSSID = connectedSSID;
            });
          }
        } else {
          setState(() {
            status = connectionType;
          });
        }
      }

      // Check if the mobile is connected to the device
      final bool isDeviceConnected = await connectToDevice();
      await getWiFiDevices();

      if (isDeviceConnected) {
        setState(() {
          isLoading = false;
          initialSetupDone = true;
        });
      } else {
        throw "Failed to connect to the device";
      }
    } catch (e) {
      showMessage(context, "Failed to initialize the device setup");
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
        initialSetupDone = false;
        addError = e.toString();
      });
    }
  }

  Future<void> onSSIDPressed(String ssid, String password) async {
    try {
      debugPrint("Provided SSID: " + ssid + " and password: " + password);
      // Get rid of the keyboard
      if (FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
      }

      setState(() {
        addError = null;
        isLoading = true;
        selectedSSID = ssid;
        selectedPassword = password;
      });

      debugPrint("Checking if credentials are sent already");

      if (!credentialsSent) {
        setState(() {
          loaderMessage = "Sending WiFi credentials to the device";
        });

        // Send the request to the device to get the device id
        final String? id = await sendCredentialsToDevice(ssid, password);

        // Check if the device id was received successfully, and in case of success update the state
        if (id == null) {
          throw Exception("Failed to get response from the device");
        }

        showMessage(context, "Successfully updated credentials on device!");
        if (widget.changeCredentialsOnly) {
          Navigator.pop(context);
        }

        setState(() {
          loaderMessage = "Switching to initial connection";
          credentialsSent = true;
          deviceID = id;
        });
      }

      debugPrint("Checking if internet is reconnected");

      if (!internetReconnected) {
        await reconnectInternet(
          (String message) => setState(() {
            loaderMessage = message;
          }),
          status,
          initialSSID,
        );

        setState(() {
          internetReconnected = true;
          loaderMessage = "Registering the device";
        });
      }

      debugPrint("Checking if device is already registered");

      if (!deviceRegistered) {
        // Add the device to the database
        final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
        await controller.addDevice(deviceID!, context);
        showMessage(context, "Device added successfully");

        setState(() {
          isLoading = false;
          deviceRegistered = true;
        });
      }
    } on SocketException catch (e) {
      debugPrint("Caught Socket exception: " + e.toString());
      setState(() {
        isLoading = false;
        loaderMessage = null;
        addError = e.message.toString();

        if (credentialsSent && !internetReconnected) {
          initialSSID = null;
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
        loaderMessage = null;
        addError = e.toString();

        if (credentialsSent && !internetReconnected) {
          initialSSID = null;
        }
      });
    }
  }

  String getButtonText() {
    if (!initialSetupDone) {
      return "Retry device connection";
    } else if (!credentialsSent) {
      return "Resd wifi credentials";
    } else if (!internetReconnected) {
      return "Manually connect to internet and retry";
    } else {
      return "Please try again";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.changeCredentialsOnly ? const Text("Change device credentials") : const Text("Add Device"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Select a wifi for your controller to use",
                  ),
                  if (addError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Text(
                        addError!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ...!deviceRegistered
                      ? [
                          if (initialSetupDone && !credentialsSent && selectedSSID == null)
                            StreamBuilder<List<WiFiAccessPoint>>(
                              stream: WiFiScan.instance.onScannedResultsAvailable,
                              builder: (context, snapshot) => Column(
                                children: snapshot.data != null
                                    ? snapshot.data!
                                        .where((element) => element.ssid != deviceSSID)
                                        .map((ap) => AccessPointComponent(ssid: ap.ssid, onPressed: onSSIDPressed))
                                        .toList()
                                    : [],
                              ),
                            ),
                          if (addError != null)
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => initialSetupDone ? onSSIDPressed(selectedSSID!, selectedPassword!) : prepare(context),
                                  icon: const Icon(Icons.restart_alt),
                                ),
                                const SizedBox(height: 10),
                                Text(getButtonText()),
                              ],
                            ),
                        ]
                      : [
                          const Text(
                            "Device registered successfully",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text("Go back"),
                            ],
                          ),
                        ],
                ],
              ),
            ),
          ),
          if (isLoading) Loader(message: loaderMessage),
        ],
      ),
    );
  }
}
