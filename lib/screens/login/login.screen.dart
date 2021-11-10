import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController email;
  late TextEditingController password;

  final GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /**
           * Form Section
           */
          Form(
            child: Column(
              children: const [
                Text('Login'),
              ],
            ),
          ),
          /**
           * End of form section
           */
        ],
      ),
    );
  }
}
