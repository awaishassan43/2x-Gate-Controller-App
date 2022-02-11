import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/controllers/user.controller.dart';
import 'package:provider/provider.dart';

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
  return 'http://192.168.4.1:80/ssid?ssid=$ssid&password=$password';
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
