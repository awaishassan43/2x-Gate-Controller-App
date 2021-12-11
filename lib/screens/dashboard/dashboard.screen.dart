import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
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
            deviceIDs: Provider.of<UserController>(context, listen: false).profile!.devices,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container();
            }

            if (snapshot.hasError || snapshot.error != null) {
              return ErrorMessage(message: snapshot.error.toString());
            }

            return Consumer<DeviceController>(
              builder: (context, controller, _) {
                return Column(
                  children: controller.devices.entries.map((entry) {
                    final Device initialData = entry.value;

                    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: initialData.deviceRef!.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError || snapshot.error != null) {
                          return ErrorMessage(message: snapshot.error.toString());
                        }

                        final String deviceID = initialData.id;
                        Device device = initialData;

                        if (snapshot.data != null) {
                          if (!snapshot.data!.exists) {
                            return Container();
                          }

                          final Map<String, dynamic> streamData = snapshot.data!.data() as Map<String, dynamic>;
                          streamData['id'] = device.id;

                          device = Device.fromMap(streamData, ref: device.deviceRef);
                        }

                        return DeviceComponent(
                          device: device,
                          key: ValueKey(deviceID),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
