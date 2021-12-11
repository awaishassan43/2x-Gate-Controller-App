import 'package:flutter/material.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      margin: const EdgeInsets.all(20),
      content: Text(message),
    ),
  );
}

String getDeviceURL(String ssid, String password) {
  // return 'http://localhost:3000/ssid?ssid=$ssid&password=$password';
  return 'http://192.168.4.1:80/ssid?ssid=$ssid&password=$password';
}

double convertCelciusToFarenheit(double value) {
  return value * 9 / 5 + 32;
}

String getTimeString(int value) {
  if (value < 60) {
    return '${value.toString()} seconds';
  } else {
    final int remainder = value % 60;
    return '${(value / 60).toStringAsFixed(remainder == 0 ? 0 : 1)} minutes';
  }
}
