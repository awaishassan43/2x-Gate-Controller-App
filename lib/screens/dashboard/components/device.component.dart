import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/util/themes.util.dart';

class DeviceComponent extends StatelessWidget {
  final Device device;
  const DeviceComponent({
    Key? key,
    required this.device,
  }) : super(key: key);

  Widget renderRelays() {
    final List<Widget> children = [];
    final relays = device.relays;

    for (int i = 0; i < (relays.length / 2).ceil(); i++) {
      final List<Widget> rowItems = [];

      for (int j = 2 * i; j <= (2 * i) + 1; j++) {
        if (j == relays.length) {
          continue;
        }

        final String name = relays[j].name;
        final bool isOpen = relays[j].isOpen;

        rowItems.add(
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2.5),
                  CustomButton(
                    text: isOpen ? "Open" : "Closed",
                    onPressed: () {},
                    backgroundColor: isOpen ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                    borderRadius: 7.5,
                    padding: 0,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowItems,
        ),
      );
    }

    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFF1a8dff);
    final double temperature = device.temperature;
    final double humidity = device.humidity;
    final String deviceName = device.name;

    return MaterialButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          Screen.device,
          arguments: device,
        );
      },
      padding: const EdgeInsets.all(12.5),
      color: Colors.white,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          /**
           * Top Section
           */
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deviceName,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  /**
                   * Temperature
                   */
                  Row(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.device_thermostat,
                          color: iconColor,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(text: temperature.round().toString()),
                            const TextSpan(text: "\u00b0"),
                            const TextSpan(text: "C"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  /**
                   * End of temperature
                   */

                  const SizedBox(width: 5),

                  /**
                   * Humidity
                   */
                  Row(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.water_rounded,
                          color: iconColor,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(text: humidity.round().toString()),
                            const TextSpan(text: "%"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  /**
                   * End of humidity
                   */

                  IconButton(
                    constraints: const BoxConstraints(
                      maxHeight: 40,
                      maxWidth: 40,
                    ),
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.pushNamed(context, Screen.deviceSettings, arguments: device);
                    },
                  ),
                ],
              ),
            ],
          ),
          /**
           * End of top section
           */

          Container(
            color: Colors.black12,
            height: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 7.5),
          ),

          /**
           * Bottom Section
           */
          renderRelays(),
        ],
      ),
    );
  }
}
