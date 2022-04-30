import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:iot/screens/addUser/addUser.screen.dart';
import 'package:iot/screens/error/error.screen.dart';
import 'package:iot/screens/forgotPassword/forgotPassword.screen.dart';
import 'package:iot/screens/scanner/scanner.screen.dart';
import 'package:iot/screens/sharing/share.screen.dart';
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
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final Future<String> initialPath;

  @override
  void initState() {
    super.initState();
    initialPath = loadInitialScreen(context);

    FirebaseDynamicLinks.instance.onLink.listen((event) {
      print("Received stream link: $event");
      Navigator.pushNamed(context, Screen.addDevice);
    }).onError((e) {
      print("Something went wrong in stream: $e");
    });
  }

  Future<String> loadInitialScreen(BuildContext context) async {
    try {
      /// getLoggedInUser returns either a boolean value or a null value
      /// in case of null, user is logged in but not verified
      /// in case of true, the user is logged in and we need to return dashboard screen
      /// in case of false, the user is not logged in, so need to return login screen
      final bool? isUserLoggedIn = await Provider.of<UserController>(context, listen: false).getLoggedInUser();

      /// Also check if the app received a dynamic link
      final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

      print("Received initial link: $initialLink");

      if (isUserLoggedIn == null) {
        return Screen.success;
      } else if (isUserLoggedIn == false) {
        return Screen.login;
      } else {
        return Screen.dashboard;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: initialPath,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
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
          final String? error = snapshot.hasError ? snapshot.error.toString() : null;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Themes.lightTheme,
            themeMode: ThemeMode.light,
            routes: {
              Screen.login: (context) => const LoginScreen(),
              Screen.signup: (context) => const SignupScreen(),
              Screen.appSettings: (context) => const AppSettings(),
              Screen.dashboard: (context) => const Dashboard(),
              Screen.resetPassword: (context) => const ChangePasswordScreen(),
              Screen.feedback: (context) => const FeedbackScreen(),
              Screen.editPhone: (context) => const PhoneEditingScreen(),
              Screen.forgotPassword: (context) => const CustomScreen(),
              Screen.success: (context) => const SuccessScreen(),
              Screen.scanner: (context) => const ScannerScreen(),
              Screen.addUser: (context) => const AddUserScreen(),
            },
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  if (settings.name == Screen.error) {
                    final String errorMessage = error!;
                    return ErrorScreen(error: errorMessage);
                  } else if (settings.name == Screen.device) {
                    final String device = settings.arguments as String;
                    return DeviceScreen(deviceID: device);
                  } else if (settings.name == Screen.deviceSettings) {
                    final String device = settings.arguments as String;
                    return DeviceSettingsScreen(deviceID: device);
                  } else if (settings.name == Screen.addDevice) {
                    final bool changeOnly = settings.arguments != null ? settings.arguments as bool : false;
                    return AddDeviceScreen(changeCredentialsOnly: changeOnly);
                  } else if (settings.name == Screen.sharing) {
                    final Map args = settings.arguments! as Map;
                    return SharingScreen(deviceID: args["id"], deviceName: args["name"]);
                  } else {
                    return Container();
                  }
                },
              );
            },
            initialRoute: error != null ? Screen.error : snapshot.data,
          );
        }
      },
    );
  }
}
