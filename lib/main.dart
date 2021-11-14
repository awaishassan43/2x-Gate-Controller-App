import 'package:flutter/material.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/dashboard/dashboard.screen.dart';
import 'package:iot/screens/login/login.screen.dart';
import 'package:iot/screens/settings/app.screen.dart';
import 'package:iot/screens/settings/device.screen.dart';
import 'package:iot/screens/signup/signup.screen.dart';
import 'package:iot/screens/success/success.screen.dart';
import 'package:iot/util/themes.util.dart';

import 'screens/device/device.screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      themeMode: ThemeMode.light,
      routes: {
        Screen.login: (context) => const LoginScreen(),
        Screen.signup: (context) => const SignupScreen(),
        Screen.success: (context) => const SuccessScreen(),
        Screen.appSettings: (context) => const AppSettings(),
        Screen.dashboard: (context) => const Dashboard(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Screen.device) {
          return MaterialPageRoute(builder: (context) {
            final Device device = settings.arguments as Device;
            return DeviceScreen(device: device);
          });
        } else if (settings.name == Screen.deviceSettings) {
          return MaterialPageRoute(builder: (context) {
            final Device device = settings.arguments as Device;
            return DeviceSettings(device: device);
          });
        }
      },
      initialRoute: Screen.dashboard,
    );
  }
}
