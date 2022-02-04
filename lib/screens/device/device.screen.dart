import 'package:flutter/material.dart';
import '/components/loader.component.dart';
import '/controllers/device.controller.dart';
import '/enum/route.enum.dart';
import '/screens/device/components/item.component.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatefulWidget {
  final String deviceID;
  const DeviceScreen({
    Key? key,
    required this.deviceID,
  }) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool isLoading = false;

  Future<void> updateRelayStatus(BuildContext context, String relayID, bool isOpen) async {
    // final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    // final Device device = controller.devices[widget.device.id]!;

    // setState(() {
    //   isLoading = true;
    // });

    // try {
    //   device.update('isOpen', isOpen, relayID: relayID);
    //   await controller.updateDevice(device);

    //   showMessage(context, "Controller updated successfully!");
    // } catch (e) {
    //   showMessage(context, e.toString());
    // }

    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Selector<DeviceController, String>(
          selector: (context, controller) => controller.devices[widget.deviceID]!.deviceData.name,
          builder: (context, name, _) => Text(name),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              /**
               * Scrollable area
               */
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                          // children: [
                          // DeviceSensor(
                          //   sensorName: "Temperature",
                          //   value: temperature,
                          //   showDegrees: true,
                          //   unit: Provider.of<UserController>(context, listen: false).profile!.temperatureUnit,
                          //   icon: 'assets/icons/temp.png',
                          // ),
                          // const SizedBox(width: 10),
                          // DeviceSensor(
                          //   sensorName: "Humidity",
                          //   value: humidity,
                          //   showPercent: true,
                          //   icon: 'assets/icons/humidity.png',
                          // ),
                          // ],
                          ),
                      // ...relays.map((relay) {
                      //   final String name = relay.name;
                      //   final bool isOpen = relay.isOpen;

                      //   return Column(
                      //     children: [
                      //       const SizedBox(height: 30),
                      //       LargeButton(
                      //         icon: isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                      //         label: isOpen ? "Opened" : "Closed",
                      //         iconColor: isOpen ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                      //         onPressed: () {
                      //           updateRelayStatus(context, relay.id, !isOpen);
                      //         },
                      //         bottomText: name,
                      //       ),
                      //     ],
                      //   );
                      // }).toList(),
                    ],
                  ),
                ),
              ),
              /**
               * End of scrollable area
               */

              /**
               * Bottom Section
               */
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BottomSectionItem(text: "History", onPressed: () {}, icon: Icons.history),
                    BottomSectionItem(text: "Schedule", icon: Icons.history, onPressed: () {}),
                    BottomSectionItem(
                      text: "Settings",
                      icon: Icons.settings,
                      onPressed: () {
                        Navigator.pushNamed(context, Screen.deviceSettings, arguments: widget.deviceID);
                      },
                    ),
                  ],
                ),
              ),
              /**
               * End of bottom section
               */
            ],
          ),
          if (isLoading) const Loader(message: "Updating controller"),
        ],
      ),
    );
  }
}
