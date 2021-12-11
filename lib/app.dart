import 'package:flutter/material.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/add/add.screen.dart';
import 'package:iot/screens/dashboard/dashboard.screen.dart';
import 'package:iot/screens/settings/subscreens/controllerName.screen.dart';
import 'package:iot/screens/settings/subscreens/feedback.component.dart';
import 'package:iot/screens/login/login.screen.dart';
import 'package:iot/screens/settings/subscreens/name.screen.dart';
import 'package:iot/screens/settings/subscreens/password.screen.dart';
import 'package:iot/screens/settings/subscreens/phone.screen.dart';
import 'package:iot/screens/settings/app.settings.dart';
import 'package:iot/screens/settings/device.settings.dart';
import 'package:iot/screens/settings/subscreens/relayName.screen.dart';
import 'package:iot/screens/signup/signup.screen.dart';
import 'package:iot/screens/success/success.screen.dart';
import 'package:iot/util/themes.util.dart';
import 'package:provider/provider.dart';

import 'screens/device/device.screen.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late final Future<bool> initializer;

  @override
  void initState() {
    super.initState();
    initializer = Provider.of<UserController>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: initializer,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox.expand(
            child: Container(
              color: backgroundColor,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Loader(),
              ),
            ),
          );
        } else {
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const ErrorMessage();
          }

          final bool isLoggedIn = snapshot.data!;

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
              Screen.resetPassword: (context) => const ChangePasswordScreen(),
              Screen.feedback: (context) => const FeedbackScreen(),
              Screen.addDevice: (context) => const AddDeviceScreen(),
              Screen.editPhone: (context) => const PhoneEditingScreen(),
              Screen.editName: (context) => const UpdateNameScreen(),
            },
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  if (settings.name == Screen.device) {
                    final Device device = settings.arguments as Device;
                    return DeviceScreen(device: device);
                  } else if (settings.name == Screen.deviceSettings) {
                    final Device device = settings.arguments as Device;
                    return DeviceSettings(device: device);
                  } else if (settings.name == Screen.editControllerName) {
                    return EditControllerNameScreen(device: settings.arguments as Device);
                  } else if (settings.name == Screen.editRelayName) {
                    return EditRelayNameScreen(
                      device: (settings.arguments as Map<String, dynamic>)['device'],
                      relayID: (settings.arguments as Map<String, dynamic>)['relayID'],
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
            initialRoute: isLoggedIn ? Screen.dashboard : Screen.login,
          );
        }
      },
    );
  }
}
