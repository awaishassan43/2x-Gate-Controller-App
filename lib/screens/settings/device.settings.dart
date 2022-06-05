import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot/enum/access.enum.dart';
import 'package:iot/screens/settings/subscreens/editor.screen.dart';
import 'package:iot/screens/settings/subscreens/selector.screen.dart';
import 'package:iot/screens/settings/subscreens/temperature.screen.dart';
import 'package:tuple/tuple.dart';
import '/components/button.component.dart';
import '/components/loader.component.dart';
import '/controllers/device.controller.dart';
import '/controllers/user.controller.dart';
import '/enum/route.enum.dart';
import '/models/device.model.dart';
import '/util/functions.util.dart';
import 'package:provider/provider.dart';
import '/util/extensions.util.dart';
import 'components/item.component.dart';
import 'components/section.component.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final String deviceID;
  const DeviceSettingsScreen({
    Key? key,
    required this.deviceID,
  }) : super(key: key);

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  bool isLoading = false;
  String? deleteError;
  late final AccessType _accessType;

  @override
  void initState() {
    super.initState();
    _accessType = Provider.of<UserController>(context, listen: false).getAccessType(widget.deviceID);
  }

  Future<void> reboot(BuildContext context) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

    final DeviceCommands deviceCommands = controller.devices[widget.deviceID]!.deviceCommands;
    final String deviceID = widget.deviceID;

    setState(() {
      isLoading = true;
    });

    try {
      /// Taking a shortcut due to time constraint
      final Map<String, dynamic> mappedData = deviceCommands.toJson();
      final DateTime currentTime = DateTime.now();
      final DateTime expiryTime = currentTime.add(const Duration(minutes: 1));

      /// currently set to 60 seconds ahead of current time

      mappedData['request']['payload']['reboot'] = 1;
      mappedData['timestamp'] = currentTime.millisecondsSinceEpoch;
      mappedData['request']['payload']['exp'] = expiryTime.millisecondsSinceEpoch;

      controller.devices[deviceID]!.updateWithJSON(deviceCommands: mappedData);

      await controller.updateDevice(deviceID, "deviceCommands");
      showMessage(context, "Controller updated successfully!");
    } on FirebaseException catch (e) {
      showMessage(context, e.toString());
    } catch (e) {
      showMessage(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateRelay(BuildContext context, dynamic value, String relayID, String key) async {
    setState(() {
      isLoading = true;
    });

    try {
      final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
      final DeviceSettings settings = controller.devices[widget.deviceID]!.deviceSettings;

      final Map<String, dynamic> mappedData = settings.toJson();
      mappedData['value'][relayID][key] = value;

      controller.devices[widget.deviceID]!.updateWithJSON(deviceSettings: mappedData);
      await controller.updateDevice(widget.deviceID, 'deviceSettings');
    } on FirebaseException catch (e) {
      showMessage(context, e.message ?? "Something went wrong while trying to update settings");
    } catch (e) {
      showMessage(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateControllerData(BuildContext context, String key, dynamic value) async {
    try {
      final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
      final Map<String, dynamic> deviceData = controller.devices[widget.deviceID]!.deviceData.toJson();
      deviceData[key] = value;

      controller.devices[widget.deviceID]!.updateWithJSON(deviceData: deviceData);

      await controller.updateDevice(widget.deviceID, "deviceData");
    } on FirebaseException catch (e) {
      showMessage(context, e.message ?? "Something went wrong while trying to update settings");
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

  Future<void> updateControllerSettings(BuildContext context, String key, dynamic value) async {
    setState(() {
      isLoading = true;
    });

    try {
      final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
      final Map<String, dynamic> deviceSettings = controller.devices[widget.deviceID]!.deviceSettings.toJson();
      deviceSettings['value'][key] = value;

      controller.devices[widget.deviceID]!.updateWithJSON(deviceSettings: deviceSettings);

      await controller.updateDevice(widget.deviceID, "deviceSettings");
    } on FirebaseException catch (e) {
      showMessage(context, e.message ?? "Something went wrong while trying to update settings");
    } catch (e) {
      showMessage(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle netTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.black26,
    );

    final DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Settings"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Selector<DeviceController, Tuple2<DeviceSettings?, String?>>(
              selector: (context, controller) =>
                  Tuple2(controller.devices[widget.deviceID]?.deviceSettings, controller.devices[widget.deviceID]?.deviceData.name),
              builder: (context, data, _) {
                if (data.item1 == null || data.item2 == null) {
                  return Container();
                }

                final String name = data.item2!;
                final deviceSettings = data.item1!.value;
                final relay1 = deviceSettings.relay1;
                final relay2 = deviceSettings.relay2;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_accessType != AccessType.owner)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(7.5),
                        ),
                        child: const Text(
                          "These settings can only be edited by the device owner",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),

                    /**
                       * Controller name
                       */
                    Section(
                      header: "General",
                      children: [
                        SectionItem(
                          title: "Controller Name",
                          trailingText: name,
                          onTap: () {
                            navigateTo(
                              context,
                              EditorScreen(
                                initialValue: name,
                                icon: Icons.sensors,
                                title: "Name of the controller",
                                onSubmit: (name, context) => updateControllerData(context, 'name', name),
                              ),
                            );
                          },
                          showSeparator: false,
                          isDisabled: _accessType != AccessType.owner,
                          showEditIcon: true,
                        ),
                      ],
                    ),

                    /**
                       * Relay 1
                       */
                    Section(
                      header: relay1.name,
                      children: [
                        SectionItem(
                          title: "Name",
                          isDisabled: _accessType != AccessType.owner,
                          subtitleText: "Change the name of the relay",
                          trailingText: relay1.name,
                          showEditIcon: true,
                          onTap: () {
                            navigateTo(
                              context,
                              EditorScreen(
                                initialValue: relay1.name,
                                title: "Relay Name",
                                icon: Icons.lock,
                                onSubmit: (name, context) => updateRelay(context, name, 'Relay1', 'Name'),
                              ),
                            );
                          },
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Output Time",
                          subtitleText: "Duration",
                          trailingText: getTimeString(relay1.outTime),
                          showChevron: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return SelectorScreen<int>(
                                  title: "Output Time",
                                  items: const [1, 5, 300, 1800],
                                  selectedItem: relay1.outTime,
                                  isTime: true,
                                  deviceID: widget.deviceID,
                                  relayID: 'Relay1',
                                  mapKey: 'OutTime',
                                  updateDeviceSettings: true,
                                );
                              },
                            ));
                          },
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "External Input",
                          subtitleText: "Enable/Disable relay output",
                          onSwitchPressed: (value) => updateRelay(context, value, 'Relay1', 'ExtInput'),
                          switchValue: relay1.extInput,
                          showSwitch: true,
                          onTap: () => updateRelay(context, !relay1.extInput, 'Relay1', 'ExtInput'),
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Auto Close",
                          subtitleText: "Automatically close the door at a specified time",
                          trailingText: relay1.autoClose != 0 ? getTimeString(relay1.autoClose) : "Disabled",
                          showChevron: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return SelectorScreen<int?>(
                                  title: "Auto Close Time",
                                  items: const [0, 30, 60, 90, 120, 150],
                                  selectedItem: relay1.autoClose,
                                  deviceID: widget.deviceID,
                                  disabledText: "Disable Auto Close",
                                  disabledValue: 0,
                                  relayID: 'Relay1',
                                  mapKey: 'autoClose',
                                  updateDeviceSettings: true,
                                );
                              },
                            ));
                          },
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Schedules",
                          subtitleText: "Open and close the door at a specified time",
                          onTap: () => Navigator.pushNamed(context, Screen.scheduling, arguments: {
                            "relayID": "Relay1",
                            "deviceID": widget.deviceID,
                            "schedules": deviceSettings.relay1.schedules,
                          }),
                          showSeparator: false,
                        ),
                      ],
                    ),

                    /**
                       * Relay 2
                       */
                    Section(
                      header: relay2.name,
                      children: [
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Name",
                          subtitleText: "Change the name of the relay",
                          trailingText: relay2.name,
                          showEditIcon: true,
                          onTap: () {
                            navigateTo(
                              context,
                              EditorScreen(
                                initialValue: relay2.name,
                                title: "Relay Name",
                                icon: Icons.lock,
                                onSubmit: (name, context) => updateRelay(context, name, 'Relay2', 'Name'),
                              ),
                            );
                          },
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Output Time",
                          subtitleText: "Duration",
                          trailingText: getTimeString(relay2.outTime),
                          showChevron: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return SelectorScreen<int>(
                                  title: "Output Time",
                                  items: const [1, 5, 300, 1800],
                                  selectedItem: relay2.outTime,
                                  deviceID: widget.deviceID,
                                  relayID: 'Relay2',
                                  mapKey: 'OutTime',
                                  updateDeviceSettings: true,
                                );
                              },
                            ));
                          },
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "External Input",
                          subtitleText: "Enable/Disable relay output",
                          switchValue: relay2.extInput,
                          showSwitch: true,
                          onSwitchPressed: (value) => updateRelay(context, value, 'Relay2', 'ExtInput'),
                          onTap: () => updateRelay(context, !relay2.extInput, 'Relay2', 'ExtInput'),
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Auto Close",
                          subtitleText: "Automatically close the door at a specified time",
                          trailingText: relay2.autoClose != 0 ? getTimeString(relay2.autoClose) : "Disabled",
                          showChevron: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return SelectorScreen<int?>(
                                  title: "Auto Close Time",
                                  items: const [0, 30, 60, 90, 120, 150],
                                  selectedItem: relay2.autoClose,
                                  disabledText: "Disable Auto Close",
                                  disabledValue: 0,
                                  deviceID: widget.deviceID,
                                  relayID: 'Relay2',
                                  mapKey: 'autoClose',
                                  updateDeviceSettings: true,
                                );
                              },
                            ));
                          },
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Scheduled",
                          subtitleText: "Open and close the door at a specified time",
                          onTap: () => Navigator.pushNamed(context, Screen.scheduling, arguments: {
                            "relayID": "Relay2",
                            "deviceID": widget.deviceID,
                            "schedules": deviceSettings.relay2.schedules,
                          }),
                          showSeparator: false,
                        ),
                      ],
                    ),

                    /**
                       * Alerts
                       */
                    Section(
                      header: "Alerts",
                      subHeader: "[Premium Feature]",
                      children: [
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "On Close",
                          showSwitch: true,
                          onSwitchPressed: (value) => updateControllerSettings(context, 'alertOnClose', value),
                          switchValue: deviceSettings.alertOnClose,
                          onTap: () => updateControllerSettings(context, 'alertOnClose', !deviceSettings.alertOnClose),
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "On Open",
                          onSwitchPressed: (value) => updateControllerSettings(context, 'alertOnOpen', value),
                          switchValue: deviceSettings.alertOnOpen,
                          showSwitch: true,
                          onTap: () => updateControllerSettings(context, 'alertOnOpen', !deviceSettings.alertOnOpen),
                        ),
                        // SectionItem(
                        // isDisabled: _accessType != AccessType.owner,
                        //   title: "Open Alert",
                        //   subtitleText: "Alert if door is left open",
                        //   trailingText: deviceSettings.remainedOpenAlert == null ? "Don't alert" : getTimeString(device.remainedOpenAlert!),
                        //   showChevron: true,
                        //   onTap: () {
                        //     Navigator.push(context, MaterialPageRoute(
                        //       builder: (context) {
                        //         return SelectorScreen<int?>(
                        //           title: "On Remained Open Alert",
                        //           items: const [30, 60, 90, 120, 150, null],
                        //           selectedItem: device.remainedOpenAlert,
                        //           deviceID: device.id,
                        //           mapKey: 'remainedOpenAlert',
                        //         );
                        //       },
                        //     ));
                        //   },
                        // ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Night Alert",
                          subtitleText: "Alert if door is left open",
                          onTap: () => updateControllerSettings(context, 'nightAlert', !deviceSettings.nightAlert),
                          onSwitchPressed: (value) => updateControllerSettings(context, 'nightAlert', value),
                          switchValue: deviceSettings.nightAlert,
                          showSwitch: true,
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Temperature Alert",
                          showEditIcon: true,
                          subtitleText: "Alert if temperature exceeds",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return TemperatureAlertScreen(deviceID: widget.deviceID);
                            }));
                          },
                          trailingText:
                              getTemperatureValue(context, deviceSettings.temperatureAlert, onNullMessage: 'Don\'t Alert', decimalPlaces: 1),
                        ),
                      ],
                    ),
                    Section(
                      header: "Info",
                      children: [
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Firmware",
                          onTap: () {},
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Date",
                          trailingText: "${today.day} ${today.getMonth} ${today.year}",
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "Time",
                          trailingText: Provider.of<UserController>(context, listen: false).profile!.is24Hours
                              ? DateFormat("HH:mm").format(today)
                              : DateFormat("hh:mm a").format(today),
                        ),
                        Selector<DeviceController, DeviceData>(
                          selector: (context, controller) => controller.devices[widget.deviceID]!.deviceData,
                          builder: (context, data, _) {
                            final payload = data.state.payload;

                            return SectionItem(
                              isDisabled: _accessType != AccessType.owner,
                              title: "Network",
                              subtitle: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Strength", style: netTextStyle),
                                      Text(payload.Strength.toString(), style: netTextStyle),
                                    ],
                                  ),
                                  const SizedBox(height: 3.5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Mac ID", style: netTextStyle),
                                      Text(payload.Mac, style: netTextStyle),
                                    ],
                                  ),
                                  const SizedBox(height: 3.5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("IP Address", style: netTextStyle),
                                      Text(payload.Ip, style: netTextStyle),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Section(
                      header: "General",
                      children: [
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "User Guide",
                          onTap: () {},
                          showChevron: true,
                        ),
                        SectionItem(
                          isDisabled: _accessType != AccessType.owner,
                          title: "FAQ",
                          showChevron: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Selector<DeviceController, bool>(
                      selector: (context, controller) => controller.devices[widget.deviceID]!.deviceData.online,
                      builder: (context, isOnline, _) {
                        return CustomButton(
                          text: "Reboot",
                          isDisabled: !isOnline && _accessType != AccessType.owner,
                          onPressed: () => reboot(context),
                          backgroundColor: Colors.white,
                          disableElevation: true,
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    CustomButton(
                      text: "Change WiFi credentials",
                      onPressed: () => Navigator.pushNamed(context, Screen.addDevice, arguments: true),
                      textColor: Colors.blue,
                      backgroundColor: Colors.white,
                      disableElevation: true,
                      isDisabled: _accessType != AccessType.owner,
                    ),
                    const SizedBox(height: 5),
                    if (deleteError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          deleteError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    CustomButton(
                      text: "Delete Device",
                      onPressed: () {
                        try {
                          setState(() {
                            if (deleteError != null) deleteError = null;
                          });

                          Provider.of<UserController>(context, listen: false).removeDevice(context, widget.deviceID);
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                            deleteError = e.toString();
                          });

                          showMessage(context, "Failed to delete the device");
                        }
                      },
                      textColor: Colors.red,
                      backgroundColor: Colors.white,
                      disableElevation: true,
                    ),
                  ],
                );
              },
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
