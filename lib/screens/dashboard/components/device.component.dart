import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:iot/util/themes.util.dart';
import 'package:provider/provider.dart';

class DeviceComponent extends StatefulWidget {
  final Device device;
  const DeviceComponent({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceComponent> createState() => _DeviceComponentState();
}

class _DeviceComponentState extends State<DeviceComponent> {
  bool isLoading = false;

  Future<void> updateRelayStatus(BuildContext context, String relayID, bool isOpen) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;

    setState(() {
      isLoading = true;
    });

    try {
      device.update('isOpen', isOpen, relayID: relayID);
      await controller.updateDevice(device);

      showMessage(context, "Controller updated successfully!");
    } catch (e) {
      showMessage(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget renderRelays() {
    final List<Widget> children = [];
    final relays = widget.device.relays.values.toList();

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
                    onPressed: () {
                      updateRelayStatus(context, relays[j].id, !isOpen);
                    },
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
    final String humidity = widget.device.humidity == null ? '...' : widget.device.humidity!.ceil().toString();

    final String deviceName = widget.device.name;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: MaterialButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Screen.device,
                arguments: widget.device,
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
                              child: Padding(
                                padding: const EdgeInsets.all(3.5),
                                child: Image.asset(
                                  'assets/icons/temp.png',
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                            Selector<UserController, String>(
                                selector: (context, controller) => controller.profile!.temperatureUnit,
                                builder: (context, unit, _) {
                                  return RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      children: [
                                        TextSpan(text: getTemperatureValue(context, widget.device.temperature, withUnit: false)),
                                        const TextSpan(text: "\u00b0"),
                                        TextSpan(text: unit),
                                      ],
                                    ),
                                  );
                                }),
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
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.5),
                                child: Image.asset(
                                  'assets/icons/humidity.png',
                                  width: 18,
                                  height: 18,
                                ),
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
                                  TextSpan(text: humidity),
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
                            Navigator.pushNamed(context, Screen.deviceSettings, arguments: widget.device);
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
          ),
        ),
        // if (isLoading) const Loader(stretched: false),
      ],
    );
  }
}
