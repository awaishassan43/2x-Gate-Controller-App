import 'package:flutter/material.dart';
import '/components/button.component.dart';
import '/controllers/device.controller.dart';
import '/controllers/user.controller.dart';
import '/enum/route.enum.dart';
import '/models/device.model.dart';
import '/util/functions.util.dart';
import '/util/themes.util.dart';
import 'package:provider/provider.dart';

class DeviceComponent extends StatelessWidget {
  final Device device;
  const DeviceComponent({
    Key? key,
    required this.device,
  }) : super(key: key);

  Future<void> updateRelayStatus(BuildContext context, String relayID, bool isOpen) async {
    // final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    // final Device device = controller.devices[this.device.id]!;

    // controller.isLoading = true;

    // try {
    //   device.update('isOpen', isOpen, relayID: relayID);
    //   await controller.updateDevice(device);

    //   showMessage(context, "Controller updated successfully!");
    // } catch (e) {
    //   showMessage(context, e.toString());
    // }

    // controller.isLoading = false;
  }

  Widget renderRelays(BuildContext context) {
    final List<Widget> children = [];
    // final relays = device.relays.values.toList();

    // for (int i = 0; i < (relays.length / 2).ceil(); i++) {
    //   final List<Widget> rowItems = [];

    //   for (int j = 2 * i; j <= (2 * i) + 1; j++) {
    //     if (j == relays.length) {
    //       continue;
    //     }

    //     final String name = relays[j].name;
    //     final bool isOpen = relays[j].isOpen;

    //     rowItems.add(
    //       Expanded(
    //         child: Container(
    //           padding: const EdgeInsets.all(10),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.stretch,
    //             children: [
    //               Text(
    //                 name,
    //                 style: const TextStyle(
    //                   fontSize: 13,
    //                   color: textColor,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //               const SizedBox(height: 2.5),
    //               CustomButton(
    //                 text: isOpen ? "Open" : "Closed",
    //                 onPressed: () {
    //                   updateRelayStatus(context, relays[j].id, !isOpen);
    //                 },
    //                 backgroundColor: isOpen ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
    //                 borderRadius: 7.5,
    //                 padding: 0,
    //                 textColor: Colors.white,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   }

    //   children.add(
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: rowItems,
    //     ),
    //   );
    // }

    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    const String humidity = '0';
    final String deviceName = device.deviceData.name;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: MaterialButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Screen.device,
                arguments: device.deviceSettings.deviceId,
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
                                        TextSpan(text: getTemperatureValue(context, 0, withUnit: false)),
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
                              text: const TextSpan(
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(text: humidity),
                                  TextSpan(text: "%"),
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
                            Navigator.pushNamed(context, Screen.deviceSettings, arguments: device.deviceSettings.deviceId);
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
                renderRelays(context),
              ],
            ),
          ),
        ),
        // if (isLoading) const Loader(stretched: false),
      ],
    );
  }
}
