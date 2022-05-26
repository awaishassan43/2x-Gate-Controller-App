import 'package:flutter/material.dart';
import 'package:iot/components/largeButton.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/device/components/sensor.component.dart';
import 'package:iot/util/functions.util.dart';
import 'package:iot/util/themes.util.dart';
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
  bool isFirstRelayDisabled = false;
  bool isSecondRelayDisabled = false;

  /// updateRelayStatus
  /// Here's how sending a opening/closing command to a particular relay works
  /// the "deviceCommands" collection handles the commands that the app sends to the device
  /// this function takes in the relay id.... and sends the opposite of the current state of the
  /// respective relay
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
      /// Mapping the deviceCommands object to JSON
      final Map<String, dynamic> mappedData = deviceCommands.toJson();

      /// Setting the current time, as well as expiry time of the command sent to the database
      final DateTime currentTime = DateTime.now();
      final DateTime expiryTime = currentTime.add(const Duration(minutes: 1));

      /// currently set to 60 seconds ahead of current time
      mappedData['request']['payload']['reboot'] = 0;
      mappedData['request']['payload']['test'] = relayID;
      mappedData['request']['payload']['state'] = initialState == 1 ? "CLOSE" : "OPEN";
      mappedData['timestamp'] = currentTime.millisecondsSinceEpoch;
      mappedData['request']['payload']['exp'] = expiryTime.millisecondsSinceEpoch;

      /// updating the device data
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
               * Note
               */
              Selector<DeviceController, bool>(
                selector: (context, controller) => controller.devices[widget.deviceID]!.deviceData.online,
                builder: (context, isOnline, _) {
                  return isOnline
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.wifi_off,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text('Device is offline'),
                            ],
                          ),
                        );
                },
              ),

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
                        final deviceData = tuple.item2;
                        final deviceState = deviceData.state.payload;

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
                              onPressed: deviceData.online ? () => updateRelayStatus(context, 1) : null,
                              bottomText: deviceSettings.relay1.name,
                            ),
                            const SizedBox(height: 30),
                            LargeButton(
                              icon: deviceState.state2 == 1 ? Icons.lock_open_rounded : Icons.lock_rounded,
                              label: deviceState.state2 == 1 ? "Opened" : "Closed",
                              iconColor: deviceState.state2 == 1 ? const Color(0xFFfc4646) : const Color(0xFF00e6c3),
                              onPressed: deviceData.online ? () => updateRelayStatus(context, 2) : null,
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(7.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // BottomSectionItem(text: "History", onPressed: () {}, icon: Icons.history),
                      // BottomSectionItem(text: "Schedule", icon: Icons.history, onPressed: () {}),
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
