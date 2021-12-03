import 'package:flutter/material.dart';
import 'package:iot/components/largeButton.component.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/device/components/item.component.dart';
import 'package:iot/screens/device/components/sensor.component.dart';
import 'package:iot/models/relay.model.dart';

class DeviceScreen extends StatelessWidget {
  final Device device;
  const DeviceScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String temperature = device.temperature == null ? '...' : device.temperature!.round().toString();
    final String humidity = device.humidity == null ? '...' : device.humidity!.toStringAsFixed(1);
    final String deviceName = device.name;
    final List<Relay> relays = device.relays;

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /**
           * Scrollable area
           */
          Expanded(
            child: SingleChildScrollView(
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
                          unit: "C",
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
