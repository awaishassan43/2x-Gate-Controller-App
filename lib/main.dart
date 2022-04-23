import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iot/util/notification.util.dart';
import '/app.dart';
import '/controllers/device.controller.dart';
import '/controllers/user.controller.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeNotifications();
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
