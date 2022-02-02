import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
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
          Selector<DeviceController, int>(
            selector: (context, controller) => controller.devices.length,
            builder: (context, devices, _) {
              return devices > 0
                  ? Container()
                  : IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Screen.addDevice);
                      },
                      icon: const Icon(Icons.add),
                    );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, Screen.appSettings);
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<void>(
              future: controller.loadDevices(context),
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
                        return Container();
                        /**
                        return StreamBuilder<DatabaseEvent>(
                          stream: initialData.stream!,
                          builder: (context, snapshot) {
                            if (snapshot.hasError || snapshot.error != null) {
                              return ErrorMessage(message: snapshot.error.toString());
                            }

                            final String deviceID = initialData.id;
                            Device device = initialData;

                            if (snapshot.data != null) {
                              final DataSnapshot snapshotData = snapshot.data!.snapshot;

                              if (!snapshotData.exists) {
                                return Container();
                              }

                              final Map<String, dynamic> streamData = (snapshotData.value as Map<Object?, Object?>).cast<String, dynamic>();
                              streamData['id'] = device.id;

                              device.updateUsingMap(streamData);
                            }

                            return DeviceComponent(
                              device: device,
                              key: ValueKey(deviceID),
                            );
                          },
                        );
                      */
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
          Selector<DeviceController, bool>(
            selector: (context, controller) => controller.isLoading,
            builder: (context, isLoading, _) {
              return isLoading ? const Loader(message: "Updating the controller") : Container();
            },
          ),
        ],
      ),
    );
  }
}
