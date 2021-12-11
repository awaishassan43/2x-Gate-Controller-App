import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/largeButton.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/device/components/item.component.dart';
import 'package:iot/screens/device/components/sensor.component.dart';
import 'package:iot/models/relay.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatefulWidget {
  final Device device;
  const DeviceScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool isLoading = false;

  Future<void> updateRelayStatus(BuildContext context, String relayID, bool isOpen) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;

    setState(() {
      isLoading = true;
    });

    try {
      device.updateDevice('isOpen', isOpen, relayID: relayID);
      await controller.updateDevice(device);

      showMessage(context, "Controller updated successfully!");
    } catch (e) {
      showMessage(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              /**
               * Scrollable area
               */
              Expanded(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: widget.device.deviceRef!.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError || snapshot.error != null) {
                        return ErrorMessage(message: snapshot.error.toString());
                      }

                      Device tempDevice = widget.device;

                      if (snapshot.data != null) {
                        if (!snapshot.data!.exists) {
                          return Container();
                        }

                        final Map<String, dynamic> streamData = snapshot.data!.data() as Map<String, dynamic>;
                        streamData['id'] = tempDevice.id;

                        tempDevice = Device.fromMap(streamData, ref: tempDevice.deviceRef);
                      }

                      final String temperature = getTemperatureValue(context, tempDevice.temperature, withUnit: false);
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
                                      onPressed: () {
                                        updateRelayStatus(context, relay.id, !isOpen);
                                      },
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
                        Navigator.pushNamed(context, Screen.deviceSettings, arguments: widget.device);
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
