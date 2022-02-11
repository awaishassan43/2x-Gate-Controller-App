import 'package:flutter/material.dart';
import 'package:iot/components/largeButton.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/device/components/sensor.component.dart';
import 'package:iot/util/functions.util.dart';
import 'package:tuple/tuple.dart';
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

  Future<void> updateRelayStatus(BuildContext context, int relayID) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

    final deviceData = controller.devices[widget.deviceID]!.deviceData.state.payload;
    final DeviceCommands deviceCommands = controller.devices[widget.deviceID]!.deviceCommands;

    final int initialState = relayID == 1 ? deviceData.state1 : deviceData.state2;
    final String deviceID = widget.deviceID;

    setState(() {
      isLoading = true;
    });

    try {
      /// Taking a shortcut due to time constraint
      final Map<String, dynamic> mappedData = deviceCommands.toJson();

      mappedData['request']['payload']['test'] = relayID;
      mappedData['request']['payload']['state'] = initialState == 1 ? "CLOSE" : "OPEN";

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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Selector<DeviceController, Tuple2<DeviceSettings, DeviceData>>(
                      selector: (context, controller) => Tuple2(
                        controller.devices[widget.deviceID]!.deviceSettings,
                        controller.devices[widget.deviceID]!.deviceData,
                      ),
                      builder: (context, tuple, _) {
                        final deviceSettings = tuple.item1.value;
                        final deviceState = tuple.item2.state.payload;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                DeviceSensor(
                                  sensorName: "Temperature",
                                  value: deviceState.Temp,
                                  showDegrees: true,
                                  unit: Provider.of<UserController>(context, listen: false).profile!.temperatureUnit,
                                  icon: 'assets/icons/temp.png',
                                ),
                                const SizedBox(width: 10),
                                DeviceSensor(
                                  sensorName: "Humidity",
                                  value: deviceState.humidity,
                                  showPercent: true,
                                  icon: 'assets/icons/humidity.png',
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            LargeButton(
                              icon: deviceState.state1 == 1 ? Icons.lock_open_rounded : Icons.lock_rounded,
                              label: deviceState.state1 == 1 ? "Opened" : "Closed",
                              iconColor: deviceState.state1 == 1 ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                              onPressed: () {
                                updateRelayStatus(context, 1);
                              },
                              bottomText: deviceSettings.relay1.name,
                            ),
                            const SizedBox(height: 30),
                            LargeButton(
                              icon: deviceState.state2 == 1 ? Icons.lock_open_rounded : Icons.lock_rounded,
                              label: deviceState.state2 == 1 ? "Opened" : "Closed",
                              iconColor: deviceState.state2 == 1 ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                              onPressed: () {
                                updateRelayStatus(context, 2);
                              },
                              bottomText: deviceSettings.relay2.name,
                            ),
                          ],
                        );
                      },
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
