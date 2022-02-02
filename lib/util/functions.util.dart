import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
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
  return data.values.toList().cast<T>();
}

Map listToMap(List data) {
  return data.asMap();
}

List<T> castList<T>(List? items) {
  return items != null ? items.cast<T>() : [];
}

Map<String, dynamic> objectToMap(Object? value) {
  final Map<String, dynamic> mappedValue = value == null ? {} : (value as Map<Object?, Object?>).cast<String, dynamic>();
  return mappedValue;
}

String getDeviceURL(String ssid, String password) {
  // return 'http://localhost:3000/ssid?ssid=$ssid&password=$password';
  return 'http://192.168.4.1:80/ssid?ssid=$ssid&password=$password';
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
