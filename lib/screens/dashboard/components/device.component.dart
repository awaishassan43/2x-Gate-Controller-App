import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import '/controllers/user.controller.dart';
import '/enum/route.enum.dart';
import '/models/device.model.dart';
import '/util/functions.util.dart';
import '/util/themes.util.dart';
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

  Future<void> updateRelayStatus(BuildContext context, int relayID) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

    final DeviceCommands deviceCommands = widget.device.deviceCommands;
    final deviceData = widget.device.deviceData.state.payload;
    final int initialState = relayID == 1 ? deviceData.state1 : deviceData.state2;

    final String deviceID = widget.device.deviceSettings.deviceId;

    setState(() {
      isLoading = true;
    });

    try {
      /// Taking a shortcut due to time constraint
      final Map<String, dynamic> mappedData = deviceCommands.toJson();

      mappedData['request']['payload']['test'] = relayID;
      mappedData['request']['payload']['state'] = initialState == 1 ? "CLOSE" : "OPEN";
      mappedData['timestamp'] = DateTime.now().millisecondsSinceEpoch;

      controller.devices[deviceID]!.updateWithJSON(deviceCommands: mappedData);

      await controller.updateDevice(deviceID, "deviceCommands");
      showMessage(context, "Controller updated successfully!");
    } catch (e) {
      showMessage(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget renderRelays(BuildContext context) {
    final deviceSettings = widget.device.deviceSettings.value;
    final deviceData = widget.device.deviceData;
    final deviceState = deviceData.state.payload;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  deviceSettings.relay1.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2.5),
                CustomButton(
                  text: deviceState.state1 == 1 ? "Open" : "Closed",
                  onPressed: () {
                    updateRelayStatus(context, 1);
                  },
                  backgroundColor: deviceState.state1 == 1 ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                  borderRadius: 7.5,
                  padding: 0,
                  textColor: Colors.white,
                  disableElevation: deviceData.online,
                  isDisabled: !deviceData.online,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  deviceSettings.relay2.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2.5),
                CustomButton(
                  text: deviceState.state2 == 1 ? "Open" : "Closed",
                  onPressed: () {
                    updateRelayStatus(context, 2);
                  },
                  backgroundColor: deviceState.state2 == 1 ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                  borderRadius: 7.5,
                  padding: 0,
                  textColor: Colors.white,
                  isDisabled: !deviceData.online,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String humidity = widget.device.deviceData.state.payload.humidity.toString();
    final double temperature = widget.device.deviceData.state.payload.Temp.toDouble();
    final String deviceName = widget.device.deviceData.name;
    final bool online = widget.device.deviceData.online;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: MaterialButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Screen.device,
                arguments: widget.device.deviceSettings.deviceId,
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
                    Expanded(
                      child: Text(
                        deviceName,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
                                      TextSpan(text: getTemperatureValue(context, temperature, withUnit: false)),
                                      const TextSpan(text: "\u00b0"),
                                      TextSpan(text: unit),
                                    ],
                                  ),
                                );
                              },
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
                            Navigator.pushNamed(context, Screen.deviceSettings, arguments: widget.device.deviceSettings.deviceId);
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
                 * Mid section
                 */
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: online
                        ? const [
                            Icon(
                              Icons.wifi,
                              color: Colors.green,
                              size: 14,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Device is online',
                              style: TextStyle(fontSize: 12),
                            ),
                          ]
                        : const [
                            Icon(
                              Icons.wifi_off,
                              color: Colors.red,
                              size: 14,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Device is offline',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                  ),
                ),

                /**
                 * Bottom Section
                 */
                renderRelays(context),
              ],
            ),
          ),
        ),
        if (isLoading) const Loader(),
      ],
    );
  }
}
