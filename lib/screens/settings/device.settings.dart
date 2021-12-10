import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/route.enum.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/settings/components/item.component.dart';
import 'package:iot/screens/settings/components/section.component.dart';
import 'package:iot/screens/settings/subscreens/selector.screen.dart';
import 'package:iot/util/extensions.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

class DeviceSettings extends StatefulWidget {
  final Device device;
  const DeviceSettings({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceSettings> createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  bool isLoading = false;
  String? deleteError;

  Future<void> onOutputTimeUpdated(BuildContext context, String relayID, int selectedValue) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;
    try {
      controller.isLoading = true;
      device.relays.firstWhere((element) => element.id == relayID).outputTime = selectedValue;
      await controller.updateDevice(device);
      Navigator.pop(context);
    } catch (e) {
      controller.outputTimeError = e.toString();
      showMessage(context, e.toString());
    }
    controller.isLoading = false;
  }

  Future<void> onAutoCloseTimeUpdated(BuildContext context, String relayID, int selectedValue) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;
    try {
      controller.isLoading = true;
      device.relays.firstWhere((element) => element.id == relayID).autoCloseTime = selectedValue;
      await controller.updateDevice(device);
      Navigator.pop(context);
    } catch (e) {
      controller.outputTimeError = e.toString();
      showMessage(context, e.toString());
    }
    controller.isLoading = false;
  }

  Future<void> onScheduledStatusUpdated(BuildContext context, String relayID, bool selectedValue) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;
    try {
      controller.isLoading = true;
      device.relays.firstWhere((element) => element.id == relayID).scheduled = selectedValue;
      await controller.updateDevice(device);
    } catch (e) {
      controller.outputTimeError = e.toString();
      showMessage(context, e.toString());
    }
    controller.isLoading = false;
  }

  Future<void> onCloseAlertUpdated(BuildContext context, int selectedValue) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;
    try {
      controller.isLoading = true;
      device.onCloseAlert = selectedValue;
      await controller.updateDevice(device);
    } catch (e) {
      controller.outputTimeError = e.toString();
      showMessage(context, e.toString());
    }
    controller.isLoading = false;
  }

  Future<void> onOpenAlertUpdated(BuildContext context, int selectedValue) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;
    try {
      controller.isLoading = true;
      device.onOpenAlert = selectedValue;
      await controller.updateDevice(device);
    } catch (e) {
      controller.outputTimeError = e.toString();
      showMessage(context, e.toString());
    }
    controller.isLoading = false;
  }

  Future<void> onRemainedOpenAlert(BuildContext context, int selectedValue) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;
    try {
      controller.isLoading = true;
      device.remainedOpenAlert = selectedValue;
      await controller.updateDevice(device);
    } catch (e) {
      controller.outputTimeError = e.toString();
      showMessage(context, e.toString());
    }
    controller.isLoading = false;
  }

  Future<void> onNightAlertUpdated(BuildContext context, bool selectedValue) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
    final Device device = controller.devices[widget.device.id]!;
    try {
      controller.isLoading = true;
      device.nightAlert = selectedValue;
      await controller.updateDevice(device);
    } catch (e) {
      controller.outputTimeError = e.toString();
      showMessage(context, e.toString());
    }
    controller.isLoading = false;
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
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: widget.device.deviceRef!.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.error != null) {
                  return ErrorMessage(message: snapshot.error.toString());
                }

                Device device = widget.device;

                if (snapshot.data != null) {
                  final Map<String, dynamic> streamData = snapshot.data!.data() as Map<String, dynamic>;
                  streamData['id'] = device.id;

                  device = Device.fromMap(streamData, ref: device.deviceRef);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Section(
                        header: "General",
                        children: [
                          SectionItem(
                            title: "Controller Name",
                            trailingText: device.name,
                            onTap: () {
                              Navigator.pushNamed(context, Screen.editControllerName, arguments: device);
                            },
                            showSeparator: false,
                            showEditIcon: true,
                          ),
                        ],
                      ),
                      ...device.relays
                          .map(
                            (relay) => Section(
                              header: "Relay 1",
                              children: [
                                SectionItem(
                                  title: "Name",
                                  subtitleText: "Automatically close the door at a specified time",
                                  trailingText: relay.name,
                                  showEditIcon: true,
                                  onTap: () {
                                    Navigator.pushNamed(context, Screen.editRelayName, arguments: {
                                      "device": device,
                                      "relayID": relay.id,
                                    });
                                  },
                                ),
                                SectionItem(
                                  title: "Output Time",
                                  subtitleText: "Duration",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SelectorScreen<int>(
                                            title: "Output Time",
                                            items: const [30, 60, 90, 120, 150],
                                            selectedItem: relay.outputTime,
                                            deviceID: device.id,
                                            relayID: relay.id,
                                            mapKey: 'outputTime',
                                          );
                                          //   selector: CustomSelector<int>(
                                          //     selectedItem: 60,
                                          //     onSelected: (int? selectedValue) {
                                          //       onOutputTimeUpdated(context, relay.id, selectedValue!);
                                          //     },
                                          //     items: const [30, 60, 90, 120, 150],
                                          //     transformer: (int value) {
                                          //       return '${(value / 60).toStringAsFixed(1)} minutes';
                                          //     },
                                          //   ),
                                          // );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                SectionItem(
                                  title: "External Input",
                                  subtitleText: "Select door sensor input",
                                  onTap: () {},
                                ),
                                SectionItem(
                                  title: "Auto Close",
                                  subtitleText: "Automatically close the dooar at a specified time",
                                  trailingText: "${relay.autoCloseTime} Seconds",
                                  showChevron: true,
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) {
                                    //       return SelectorScreen(
                                    //         title: "Auto Close Time",
                                    //         selector: CustomSelector<int>(
                                    //           selectedItem: 60,
                                    //           onSelected: (int? selectedValue) {
                                    //             onAutoCloseTimeUpdated(context, relay.id, selectedValue!);
                                    //           },
                                    //           items: const [30, 60, 90, 120, 150],
                                    //           transformer: (int value) {
                                    //             return '${(value / 60).toStringAsFixed(1)} minutes';
                                    //           },
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // );
                                  },
                                ),
                                SectionItem(
                                  title: "Scheduled",
                                  subtitleText: "Open and close the door at a specified time",
                                  trailing: Switch(
                                    value: relay.scheduled,
                                    onChanged: (value) {
                                      if (value != relay.scheduled) {
                                        onScheduledStatusUpdated(context, relay.id, value);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    onScheduledStatusUpdated(context, relay.id, !relay.scheduled);
                                  },
                                  showSeparator: false,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                      Section(
                        header: "Alerts",
                        subHeader: "[Premium Feature]",
                        children: [
                          SectionItem(
                            title: "On Close",
                            trailing: Switch(
                              onChanged: (value) {},
                              value: device.onCloseAlert != 0,
                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              // MaterialPageRoute(
                              //     builder: (context) {
                              //       return SelectorScreen(
                              //         title: "Output Time",
                              //         selector: CustomSelector<int>(
                              //           selectedItem: 60,
                              //           onSelected: (int? selectedValue) {
                              //             onCloseAlertUpdated(context, selectedValue!);
                              //           },
                              //           items: const [30, 60, 90, 120, 150],
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          SectionItem(
                            title: "On Open",
                            trailing: Switch(
                              onChanged: (value) {},
                              value: device.onOpenAlert != 0,
                            ),
                            onTap: () {},
                          ),
                          SectionItem(
                            title: "Open Alert",
                            subtitleText: "Alert if door is left open",
                            trailingText:
                                device.remainedOpenAlert <= 0 ? "Don't alert" : '${(device.remainedOpenAlert / 60).toStringAsFixed(1)} minutes',
                            showChevron: true,
                            onTap: () {},
                          ),
                          SectionItem(
                            title: "Night Alert",
                            subtitleText: "Alert if door is left open",
                            onTap: () {},
                            trailing: Switch(
                              onChanged: (value) {},
                              value: device.nightAlert,
                            ),
                          ),
                          SectionItem(
                            title: "Temperature Alert",
                            showEditIcon: true,
                            subtitleText: "Alert if temperature exceeds",
                            trailingText: device.temperatureAlert == null
                                ? "Don't alert"
                                : '${device.temperatureAlert.toString()} ${Provider.of<UserController>(context, listen: false).profile!.temperatureUnit}',
                          ),
                        ],
                      ),
                      Section(
                        header: "Info",
                        children: [
                          SectionItem(
                            title: "Firmware",
                            onTap: () {},
                            trailingText: device.firmware ?? '...',
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
                          SectionItem(
                            title: "Network",
                            subtitle: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Strength", style: netTextStyle),
                                    Text(device.networkStrength ?? '...', style: netTextStyle),
                                  ],
                                ),
                                const SizedBox(height: 3.5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Mac ID", style: netTextStyle),
                                    Text(device.macID ?? '...', style: netTextStyle),
                                  ],
                                ),
                                const SizedBox(height: 3.5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("IP Address", style: netTextStyle),
                                    Text(device.ipAddress ?? '...', style: netTextStyle),
                                  ],
                                ),
                              ],
                            ),
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

                            await Provider.of<DeviceController>(context, listen: false).removeDevice(device.id, context);
                            Navigator.pop(context);
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
                  ),
                );
              }),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
