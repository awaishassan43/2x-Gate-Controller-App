import 'package:flutter/material.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/screens/login/login.screen.dart';
import 'package:iot/screens/settings/app.screen.dart';
import 'package:iot/screens/settings/device.screen.dart';
import 'package:iot/screens/signup/signup.screen.dart';
import 'package:iot/screens/success/success.screen.dart';
import 'package:iot/util/themes.util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.lightTheme,
      themeMode: ThemeMode.light,
      routes: {
        Screen.login: (context) => const LoginScreen(),
        Screen.signup: (context) => const SignupScreen(),
        Screen.success: (context) => const SuccessScreen(),
        Screen.deviceSettings: (context) => const DeviceSettings(),
        Screen.appSettings: (context) => const AppSettings(),
      },
      initialRoute: Screen.deviceSettings,
    );
  }
}
