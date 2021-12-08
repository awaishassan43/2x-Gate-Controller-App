import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/screens/settings/components/item.component.dart';
import 'package:iot/screens/settings/components/section.component.dart';
import 'package:iot/screens/selector/selector.screen.dart';
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
                            onEdit: (String value) {},
                            showSeparator: false,
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
                                  onEdit: (String value) {},
                                ),
                                SectionItem(
                                  title: "Output Time",
                                  subtitleText: "Duration",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return const SelectorScreen(
                                          title: "Output Time",
                                          options: ["0.5 seconds", "5 seconds", "5 minutes", "30 minutes"],
                                          selectedOption: "5 seconds",
                                        );
                                      }),
                                    );
                                  },
                                ),
                                SectionItem(
                                  title: "External Input",
                                  subtitleText: "Select door sensor input",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return const SelectorScreen(
                                          title: "Door Sensor Input",
                                          options: ["External Input 1", "None"],
                                          selectedOption: "External Input 1",
                                        );
                                      }),
                                    );
                                  },
                                ),
                                SectionItem(
                                  title: "Auto Close",
                                  subtitleText: "Automatically close the dooar at a specified time",
                                  trailingText: "30 Seconds",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return const SelectorScreen(
                                          title: "Auto Close",
                                          options: ["30 seconds", "1 minutes", "2 minutes", "5 minutes", "None"],
                                          selectedOption: "30 seconds",
                                        );
                                      }),
                                    );
                                  },
                                ),
                                SectionItem(
                                  title: "Scheduled",
                                  subtitleText: "Open and close the door at a specified time",
                                  trailing: Switch(
                                    value: false,
                                    onChanged: (value) {},
                                  ),
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
                            onTap: () {},
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
                            subtitleText: "Alert if temperature exceeds",
                            trailingText: device.temperatureAlert == null
                                ? "Don't alert"
                                : '${device.temperatureAlert.toString()} ${Provider.of<UserController>(context, listen: false).profile!.temperatureUnit}',
                            onEdit: (String value) {},
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
