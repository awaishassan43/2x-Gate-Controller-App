import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot/screens/settings/subscreens/editor.screen.dart';
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

  // Future<void> onDeviceUpdated(BuildContext context, String key, bool value) async {
  //   final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
  //   final Device device = controller.devices[widget.device.id]!;

  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     device.update(key, value);
  //     await controller.updateDevice(device);

  //     showMessage(context, "Controller updated successfully!");
  //   } catch (e) {
  //     controller.outputTimeError = e.toString();
  //     showMessage(context, e.toString());
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // Future<void> onScheduledStatusUpdated(BuildContext context, String relayID, bool selectedValue) async {
  //   final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
  //   final Device device = controller.devices[widget.device.id]!;
  //   try {
  //     controller.isLoading = true;
  //     device.update('scheduled', selectedValue, relayID: relayID);
  //     await controller.updateDevice(device);
  //   } catch (e) {
  //     controller.outputTimeError = e.toString();
  //     showMessage(context, e.toString());
  //   }
  //   controller.isLoading = false;
  // }

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
            child: Selector<DeviceController, Tuple2<DeviceSettings, String>>(
              selector: (context, controller) =>
                  Tuple2(controller.devices[widget.deviceID]!.deviceSettings, controller.devices[widget.deviceID]!.deviceData.name),
              builder: (context, data, _) {
                final String name = data.item2;
                final deviceSettings = data.item1.value;
                final relay1 = deviceSettings.relay1;
                final relay2 = deviceSettings.relay2;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                onSubmit: (String name) async {
                                  final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
                                  final DeviceData deviceData = controller.devices[widget.deviceID]!.deviceData;
                                  deviceData.name = name;

                                  controller.devices[widget.deviceID]!.updateWithJSON(deviceData: deviceData.toJson());

                                  await controller.updateDevice(widget.deviceID, "deviceData");
                                },
                              ),
                            );
                          },
                          showSeparator: false,
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
                          subtitleText: "Automatically close the door at a specified time",
                          trailingText: relay1.name,
                          showEditIcon: true,
                          onTap: () {
                            navigateTo(
                              context,
                              EditorScreen(
                                initialValue: relay1.name,
                                title: "Relay Name",
                                icon: Icons.lock,
                                onSubmit: (String name) async {
                                  final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
                                  final DeviceSettings settings = controller.devices[widget.deviceID]!.deviceSettings;
                                  settings.value.relay1.name = name;

                                  controller.devices[widget.deviceID]!.updateWithJSON(deviceSettings: settings.toJson());
                                  await controller.updateDevice(widget.deviceID, 'deviceSettings');
                                },
                              ),
                            );
                          },
                        ),
                        SectionItem(
                          title: "Output Time",
                          subtitleText: "Duration",
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) {
                            //     return SelectorScreen<int>(
                            //       title: "Output Time",
                            //       items: const [1, 5, 300, 1800],
                            //       selectedItem: relay.outputTime,
                            //       deviceID: device.id,
                            //       relayID: relay.id,
                            //       mapKey: 'outputTime',
                            //     );
                            //   },
                            // ));
                          },
                        ),
                        SectionItem(
                          title: "External Input",
                          subtitleText: "Select door sensor input",
                          onTap: () {},
                        ),
                        SectionItem(
                          title: "Auto Close",
                          subtitleText: "Automatically close the door at a specified time",
                          trailingText: getTimeString(relay1.autoClose),
                          showChevron: true,
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) {
                            //     return SelectorScreen<int?>(
                            //       title: "Auto Close Time",
                            //       items: const [30, 60, 90, 120, 150, null],
                            //       selectedItem: relay.autoCloseTime,
                            //       deviceID: device.id,
                            //       relayID: relay.id,
                            //       mapKey: 'autoClose',
                            //     );
                            //   },
                            // ));
                          },
                        ),
                        // SectionItem(
                        //   title: "Scheduled",
                        //   subtitleText: "Open and close the door at a specified time",
                        //   trailing: Switch(
                        //     value: relay.scheduled,
                        //     onChanged: (value) {
                        //       if (value != relay.scheduled) {
                        //         onScheduledStatusUpdated(context, relay.id, value);
                        //       }
                        //     },
                        //   ),
                        //   onTap: () {
                        //     onScheduledStatusUpdated(context, relay.id, !relay.scheduled);
                        //   },
                        //   showSeparator: false,
                        // ),
                      ],
                    ),

                    /**
                       * Relay 2
                       */
                    Section(
                      header: relay2.name,
                      children: [
                        SectionItem(
                          title: "Name",
                          subtitleText: "Automatically close the door at a specified time",
                          trailingText: relay2.name,
                          showEditIcon: true,
                          onTap: () {
                            // Navigator.pushNamed(context, Screen.editRelayName, arguments: {
                            //   "device": device,
                            //   "relayID": relay.id,
                            // });
                          },
                        ),
                        SectionItem(
                          title: "Output Time",
                          subtitleText: "Duration",
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) {
                            //     return SelectorScreen<int>(
                            //       title: "Output Time",
                            //       items: const [1, 5, 300, 1800],
                            //       selectedItem: relay.outputTime,
                            //       deviceID: device.id,
                            //       relayID: relay.id,
                            //       mapKey: 'outputTime',
                            //     );
                            //   },
                            // ));
                          },
                        ),
                        SectionItem(
                          title: "External Input",
                          subtitleText: "Select door sensor input",
                          onTap: () {},
                        ),
                        SectionItem(
                          title: "Auto Close",
                          subtitleText: "Automatically close the door at a specified time",
                          trailingText: getTimeString(relay2.autoClose),
                          showChevron: true,
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) {
                            //     return SelectorScreen<int?>(
                            //       title: "Auto Close Time",
                            //       items: const [30, 60, 90, 120, 150, null],
                            //       selectedItem: relay.autoCloseTime,
                            //       deviceID: device.id,
                            //       relayID: relay.id,
                            //       mapKey: 'autoClose',
                            //     );
                            //   },
                            // ));
                          },
                        ),
                        // SectionItem(
                        //   title: "Scheduled",
                        //   subtitleText: "Open and close the door at a specified time",
                        //   trailing: Switch(
                        //     value: relay.scheduled,
                        //     onChanged: (value) {
                        //       if (value != relay.scheduled) {
                        //         onScheduledStatusUpdated(context, relay.id, value);
                        //       }
                        //     },
                        //   ),
                        //   onTap: () {
                        //     onScheduledStatusUpdated(context, relay.id, !relay.scheduled);
                        //   },
                        //   showSeparator: false,
                        // ),
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
                          title: "On Close",
                          trailing: Switch(
                            onChanged: (value) {
                              // onDeviceUpdated(context, 'onCloseAlert', value);
                            },
                            value: deviceSettings.alertOnClose,
                          ),
                          onTap: () {
                            // onDeviceUpdated(context, 'onCloseAlert', !device.onCloseAlert);
                          },
                        ),
                        SectionItem(
                          title: "On Open",
                          trailing: Switch(
                            onChanged: (value) {
                              // onDeviceUpdated(context, 'onOpenAlert', value);
                            },
                            value: deviceSettings.alertOnOpen,
                          ),
                          onTap: () {
                            // onDeviceUpdated(context, 'onOpenAlert', !device.onOpenAlert);
                          },
                        ),
                        // SectionItem(
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
                          title: "Night Alert",
                          subtitleText: "Alert if door is left open",
                          onTap: () {
                            // onDeviceUpdated(context, 'nightAlert', !device.nightAlert);
                          },
                          trailing: Switch(
                            onChanged: (value) {
                              // onDeviceUpdated(context, 'nightAlert', value);
                            },
                            value: deviceSettings.nightAlert,
                          ),
                        ),
                        SectionItem(
                          title: "Temperature Alert",
                          showEditIcon: true,
                          subtitleText: "Alert if temperature exceeds",
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) {
                            //   return TemperatureAlertScreen(device: device);
                            // }));
                          },
                          // trailingText: getTemperatureValue(context, device.temperatureAlert, onNullMessage: 'Don\'t Alert', decimalPlaces: 1),
                        ),
                      ],
                    ),
                    Section(
                      header: "Info",
                      children: [
                        SectionItem(
                          title: "Firmware",
                          onTap: () {},
                          // trailingText: device.firmware ?? '...',
                        ),
                        SectionItem(
                          title: "Date",
                          trailingText: "${today.day} ${today.getMonth} ${today.year}",
                        ),
                        SectionItem(
                          title: "Time",
                          trailingText: Provider.of<UserController>(context, listen: false).profile!.is24Hours
                              ? DateFormat("HH:mm").format(today)
                              : DateFormat("hh:mm a").format(today),
                        ),
                        const SectionItem(
                          title: "Network",
                          // subtitle: Column(
                          //   children: [
                          //     Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         const Text("Strength", style: netTextStyle),
                          //         Text(device.networkStrength ?? '...', style: netTextStyle),
                          //       ],
                          //     ),
                          //     const SizedBox(height: 3.5),
                          //     Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         const Text("Mac ID", style: netTextStyle),
                          //         Text(device.macID ?? '...', style: netTextStyle),
                          //       ],
                          //     ),
                          //     const SizedBox(height: 3.5),
                          //     Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         const Text("IP Address", style: netTextStyle),
                          //         Text(device.ipAddress ?? '...', style: netTextStyle),
                          //       ],
                          //     ),
                          //   ],
                          // ),
                        ),
                      ],
                    ),
                    Section(
                      header: "General",
                      children: [
                        SectionItem(
                          title: "User Guide",
                          onTap: () {},
                          showChevron: true,
                        ),
                        SectionItem(
                          title: "FAQ",
                          showChevron: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: "Reboot",
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      disableElevation: true,
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
                      onPressed: () async {
                        try {
                          setState(() {
                            if (deleteError != null) deleteError = null;
                            isLoading = true;
                          });

                          await Provider.of<UserController>(context, listen: false).removeDevice(widget.deviceID);
                          Navigator.popUntil(context, ModalRoute.withName(Screen.dashboard));
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
