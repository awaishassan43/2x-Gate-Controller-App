import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:location/location.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:provider/provider.dart';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '/controllers/user.controller.dart';
import 'constants.util.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 1500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      margin: const EdgeInsets.all(20),
      content: Text(message),
    ),
  );
}

List<T> mapToList<T>(Map data) {
  try {
    return data.values.toList().cast<T>();
  } catch (e) {
    throw "Failed to convert map to list: ${e.toString()}";
  }
}

Map listToMap(List data) {
  try {
    return data.asMap();
  } catch (e) {
    throw "Failed to convert list to map: ${e.toString()}";
  }
}

List<T> castList<T>(List? items) {
  try {
    return items != null ? items.cast<T>() : [];
  } catch (e) {
    throw "Failed to convert list type: ${e.toString()}";
  }
}

Map<String, dynamic> objectToMap(Object? value) {
  final Map<String, dynamic> mappedValue = value == null ? {} : (value as Map<Object?, Object?>).cast<String, dynamic>();
  return mappedValue;
}

String getDeviceURL(String ssid, String password) {
  return 'http://$deviceIP/ssid?ssid=$ssid&password=$password';
}

Uri getCloudURL(String id) {
  return Uri.parse('https://us-central1-luminous-shadow-330923.cloudfunctions.net/createDevice?uid=' + id);
}

double convertCelciusToFarenheit(double value) {
  return value * 9 / 5 + 32;
}

double convertFarenheitToCelcius(double value) {
  return (value - 32) * 5 / 9;
}

String getTimeString(int value) {
  if (value < 60) {
    return '${value.toString()} seconds';
  } else {
    final int remainder = value % 60;
    return '${(value / 60).toStringAsFixed(remainder == 0 ? 0 : 1)} minutes';
  }
}

String getTemperatureValue(BuildContext context, double? temperature, {int decimalPlaces = 0, String onNullMessage = '...', withUnit = true}) {
  if (temperature == null) {
    return onNullMessage;
  } else {
    final String unit = Provider.of<UserController>(context, listen: false).profile!.temperatureUnit;

    if (unit == "F") {
      return '${convertCelciusToFarenheit(temperature).toStringAsFixed(decimalPlaces)}${withUnit ? '\u00b0$unit' : ''}';
    } else {
      return '${temperature.toStringAsFixed(decimalPlaces)}${withUnit ? '\u00b0$unit' : ''}';
    }
  }
}

Future<Map<String, dynamic>> convertToMap(dynamic data) async {
  final Map<String, dynamic> parsedData = await compute(_converterIsolate, data);
  return parsedData;
}

Map<String, dynamic> _converterIsolate(dynamic data) {
  final String encodedData = jsonEncode(data);
  final Map<String, dynamic> parsedData = jsonDecode(encodedData);

  return parsedData;
}

void navigateTo(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

double dynamicToDouble(dynamic value) {
  if (value.runtimeType.toString() == "int") {
    return (value as int).toDouble();
  }

  return (value as double);
}

Future<ConnectivityStatus> verifySetup() async {
  debugPrint("Verifying the setup");

  // Check the location permission status
  PermissionStatus requestPermission = await Location.instance.hasPermission();

  // If not granted, then request the permission
  if (requestPermission == PermissionStatus.deniedForever) {
    throw "Please allow location permissions from the app settings";
  } else if (requestPermission != PermissionStatus.granted) {
    requestPermission = await Location.instance.requestPermission();

    if (requestPermission != PermissionStatus.granted) {
      throw "This feature requires location permission";
    }
  }

  debugPrint("Location permission granted");

  // Check if the location is enabled
  bool isLocationEnabled = await Location.instance.serviceEnabled();

  // If not enabled, then request the location to be enabled
  if (!isLocationEnabled) {
    isLocationEnabled = await Location.instance.requestService();

    if (!isLocationEnabled) {
      throw "Please enable the location services";
    }
  }

  debugPrint("Location services enabled");

  if (await WiFiScan.instance.canGetScannedResults(askPermissions: true) != CanGetScannedResults.yes) {
    debugPrint("WiFi scan not allowed");

    throw "WiFi scan not allowed";
  }

  final ConnectivityStatus status = await Connectivity().checkConnectivity();
  return status;
}

Future<bool> connectToDevice() async {
  // Enable wifi if not
  if (!await WiFiForIoTPlugin.isEnabled()) {
    debugPrint("Enabling wifi");
    await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);

    debugPrint("Waiting for the results to come in");
    await WiFiScan.instance.onScannedResultsAvailable.firstWhere((list) {
      for (WiFiAccessPoint ap in list) {
        if (ap.ssid == deviceSSID) {
          return true;
        }
      }

      return false;
    }).timeout(const Duration(seconds: 15000));
  }

  debugPrint("Wifi enabled");

  // Check if already connected
  if (await WiFiForIoTPlugin.isConnected()) {
    final String? connectedSSID = await getConnectedWiFi();

    if (connectedSSID != null && connectedSSID == deviceSSID) {
      debugPrint("WiFi is already connected with: " + connectedSSID.toString());
      return true;
    }
  }

  final bool isConnected =
      await WiFiForIoTPlugin.findAndConnect(deviceSSID, password: devicePassword, withInternet: true).timeout(const Duration(seconds: 10));

  debugPrint("WiFi connected: " + isConnected.toString());

  return isConnected;
}

Future<String?> getConnectedWiFi() async {
  final String? connectedSSID = await WiFiForIoTPlugin.getSSID();
  return connectedSSID;
}

Future<String> sendCredentialsToDevice(String ssid, String password) async {
  try {
    final Uri url = Uri.parse(getDeviceURL(ssid, password));
    final http.Response response = await http.post(url).timeout(
      const Duration(milliseconds: 15000),
      onTimeout: () {
        throw "Timed out while trying to send credentials to the device";
      },
    );

    debugPrint("Response: " + response.body.toString());

    return response.body;
  } catch (e) {
    rethrow;
  }
}

Future<void> reconnectInternet(ConnectivityStatus status, String? initialSSID) async {
  try {
    bool isConnected = false;

    if (initialSSID != null) {
      final bool isDisconnected = await WiFiForIoTPlugin.disconnect();

      if (!isDisconnected) {
        throw "Failed to disconnect from the device";
      } else if (initialSSID == deviceSSID) {
        throw "The initially connected WiFi was the device's - Please connect to another wifi or cellular network and press the continue button";
      }

      isConnected = await WiFiForIoTPlugin.connect(initialSSID);

      if (!isConnected) {
        throw "Failed to reconnect to " + initialSSID;
      }
    } else if (status == ConnectivityStatus.mobile) {
      await WiFiForIoTPlugin.setEnabled(false);
    }

    await Connectivity().isConnected.firstWhere((element) => element).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw "Timed out while waiting for internet connection";
      },
    );
  } catch (e) {
    rethrow;
  }
}

Future<void> bypassDevice(BuildContext context) async {
  const String deviceID = 'esp-3c71bfab3e6c';
  final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
  await controller.addDevice(deviceID, context);
  showMessage(context, "Device added successfully");
}

// Future<void> waitForInternetConnection() async {
//   try {
//     if (!await Connectivity().checkConnection()) {
//       await Connectivity().isConnected.firstWhere((isConnected) => isConnected).timeout(timeLimit);
//     }
//   } catch (e) {
//     rethrow;
//   }
// }
