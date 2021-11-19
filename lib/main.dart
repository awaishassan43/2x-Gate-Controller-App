import 'package:flutter/material.dart';
import 'package:iot/app.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const GateController());
}

class GateController extends StatelessWidget {
  const GateController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserController(),
      builder: (context, _) {
        return const App();
      },
    );
  }
}
