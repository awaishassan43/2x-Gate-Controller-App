import 'package:flutter/material.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/dashboard/components/device.component.dart';
import 'package:iot/util/themes.util.dart';

// const List<Device> devices = [
//   {
//     "name": "Main gate",
//     "temperature": "75",
//     "humidity": "45",
//     "relays": [
//       {"name": "Gate Front", "state": 1},
//       {"name": "Gate Back", "state": 0}
//     ]
//   }
// ];

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
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
        child: Column(
          children: const [
            DeviceComponent(
              device: Device(
                name: "Main Gate",
                temperature: 24,
                humidity: 65,
                relays: [
                  Relay(name: "Gate Front", isOpen: false),
                  Relay(name: "Gate Back", isOpen: true),
                  Relay(name: "Gate Front", isOpen: false),
                  Relay(name: "Gate Back", isOpen: true),
                  Relay(name: "Gate Front", isOpen: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
