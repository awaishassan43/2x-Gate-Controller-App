import 'package:flutter/material.dart';
import 'package:iot/screens/forgotPassword/forgotPassword.screen.dart';
import '/components/error.component.dart';
import '/components/loader.component.dart';
import '/controllers/user.controller.dart';
import '/enum/route.enum.dart';
import '/screens/add/add.screen.dart';
import '/screens/dashboard/dashboard.screen.dart';
import 'screens/settings/subscreens/feedback.screen.dart';
import '/screens/login/login.screen.dart';
import '/screens/settings/subscreens/password.screen.dart';
import '/screens/settings/subscreens/phone.screen.dart';
import '/screens/settings/app.settings.dart';
import '/screens/settings/device.settings.dart';
import '/screens/signup/signup.screen.dart';
import '/screens/success/success.screen.dart';
import '/util/themes.util.dart';
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
                child: Loader(stretched: false),
              ),
            ),
          );
        } else {
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return MaterialApp(home: ErrorMessage(message: snapshot.error.toString()));
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
              Screen.editPhone: (context) => const PhoneEditingScreen(),
              Screen.forgotPassword: (context) => const CustomScreen(),
            },
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  if (settings.name == Screen.device) {
                    final String device = settings.arguments as String;
                    return DeviceScreen(deviceID: device);
                  } else if (settings.name == Screen.deviceSettings) {
                    final String device = settings.arguments as String;
                    return DeviceSettingsScreen(deviceID: device);
                  } else if (settings.name == Screen.addDevice) {
                    final bool changeOnly = settings.arguments != null ? settings.arguments as bool : false;
                    return AddDeviceScreen(changeCredentialsOnly: changeOnly);
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
