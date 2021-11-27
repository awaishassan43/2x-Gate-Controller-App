import 'package:flutter/material.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/screens/dashboard/components/device.component.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

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
          future: controller.loadDevices(
            userID: Provider.of<UserController>(context, listen: false).auth.currentUser!.uid,
          ),
          builder: (context, _) {
            return Column(
              children: controller.devices.map((device) {
                return DeviceComponent(
                  device: device,
                  key: Key(device.id),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
