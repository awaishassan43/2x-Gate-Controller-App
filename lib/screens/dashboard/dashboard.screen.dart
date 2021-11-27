import 'package:flutter/material.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceController(
        userID: Provider.of<UserController>(context, listen: false).auth.currentUser!.uid,
      ),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Screen.addDevice);
                },
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Screen.appSettings);
                },
                icon: const Icon(Icons.settings),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<void>(
                future: Provider.of<DeviceController>(context, listen: false).loadDevices(),
                builder: (context, _) {
                  return Column(
                    children: [],
                  );
                }),
          ),
        );
      },
    );
  }
}
