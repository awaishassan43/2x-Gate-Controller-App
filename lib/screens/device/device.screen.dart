import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/largeButton.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/device/components/item.component.dart';
import 'package:iot/screens/device/components/sensor.component.dart';
import 'package:iot/models/relay.model.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatelessWidget {
  final Device device;
  const DeviceScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /**
           * Scrollable area
           */
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: device.deviceRef!.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError || snapshot.error != null) {
                    return ErrorMessage(message: snapshot.error.toString());
                  }

                  Device tempDevice = device;

                  if (snapshot.data != null) {
                    final Map<String, dynamic> streamData = snapshot.data!.data() as Map<String, dynamic>;
                    streamData['id'] = tempDevice.id;

                    tempDevice = Device.fromMap(streamData, ref: tempDevice.deviceRef);
                  }

                  final String temperature = tempDevice.temperature == null ? '...' : tempDevice.temperature!.round().toString();
                  final String humidity = tempDevice.humidity == null ? '...' : tempDevice.humidity!.toStringAsFixed(1);
                  final List<Relay> relays = tempDevice.relays;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              DeviceSensor(
                                sensorName: "Temperature",
                                value: temperature,
                                showDegrees: true,
                                unit: Provider.of<UserController>(context, listen: false).profile!.temperatureUnit,
                                icon: 'assets/icons/temp.png',
                              ),
                              const SizedBox(width: 10),
                              DeviceSensor(
                                sensorName: "Humidity",
                                value: humidity,
                                showPercent: true,
                                icon: 'assets/icons/humidity.png',
                              ),
                            ],
                          ),
                          ...relays.map((relay) {
                            final String name = relay.name;
                            final bool isOpen = relay.isOpen;

                            return Column(
                              children: [
                                const SizedBox(height: 30),
                                LargeButton(
                                  icon: isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                                  label: isOpen ? "Opened" : "Closed",
                                  iconColor: isOpen ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                                  onPressed: () {},
                                  bottomText: name,
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }),
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
                    Navigator.pushNamed(context, Screen.deviceSettings, arguments: device);
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
    );
  }
}
