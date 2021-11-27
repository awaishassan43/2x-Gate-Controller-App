import 'package:flutter/material.dart';
import 'package:iot/app.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const GateController());
}

class GateController extends StatelessWidget {
  const GateController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserController()),
        ChangeNotifierProvider(create: (context) => DeviceController()),
      ],
      builder: (context, _) {
        return const App();
      },
    );
  }
}
