import 'package:flutter/material.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/screens/login/login.screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      routes: {
        Screen.login: (context) => const LoginScreen(),
      },
    );
  }
}
