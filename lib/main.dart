import 'package:flutter/material.dart';
import '/app.dart';
import '/controllers/device.controller.dart';
import '/controllers/user.controller.dart';
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
