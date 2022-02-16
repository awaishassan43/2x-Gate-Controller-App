import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import '/components/error.component.dart';
import '/components/loader.component.dart';
import '/controllers/device.controller.dart';
import '/enum/route.enum.dart';
import '/models/device.model.dart';
import '/screens/dashboard/components/device.component.dart';
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
          Selector<UserController, List<String>>(
            selector: (context, controller) => controller.profile!.devices,
            builder: (context, _, __) {
              return SingleChildScrollView(
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

                            final String deviceID = entry.key;
                            Device device = initialData;

                            return DeviceComponent(
                              device: device,
                              key: ValueKey(deviceID),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              );
            },
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
