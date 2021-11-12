import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/util/extensions.util.dart';
import 'package:iot/screens/settings/components/item.component.dart';
import 'package:iot/screens/settings/components/section.component.dart';

class DeviceSettings extends StatelessWidget {
  const DeviceSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle netTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.black26,
    );

    const TextStyle trailingTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.black87,
    );

    final DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Section(
              header: "General",
              children: [
                SectionItem(
                  title: "Controller Name",
                  trailingText: "Gate Front",
                  onEdit: () {},
                  showSeparator: false,
                ),
              ],
            ),
            Section(
              header: "Relay 1",
              children: [
                SectionItem(
                  title: "Name",
                  subtitleText: "Automatically close the door at a specified time",
                  trailingText: "Gate One",
                  onEdit: () {},
                ),
                SectionItem(
                  title: "Output Time",
                  subtitleText: "Duration",
                  onTap: () {},
                ),
                const SectionItem(
                  title: "External Input",
                  subtitleText: "Select door sensor input",
                ),
                const SectionItem(
                  title: "Auto Close",
                  subtitleText: "Automatically close the dooar at a specified time",
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
            Section(
              header: "Info",
              children: [
                SectionItem(
                  title: "Firmware",
                  onTap: () {},
                  trailing: Row(
                    children: const [
                      Text(
                        "v1.1",
                        style: trailingTextStyle,
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 30,
                      ),
                    ],
                  ),
                ),
                SectionItem(
                  title: "Date",
                  trailingText: "${today.day} ${today.getMonth} ${today.year}",
                ),
                SectionItem(
                  title: "Time",
                  trailingText: "${today.hour}:${today.minute}",
                ),
                SectionItem(
                  title: "Network",
                  subtitle: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Strength", style: netTextStyle),
                          Text("Good", style: netTextStyle),
                        ],
                      ),
                      const SizedBox(height: 3.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Mac ID", style: netTextStyle),
                          Text("16f4:12gh:1234", style: netTextStyle),
                        ],
                      ),
                      const SizedBox(height: 3.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "IP Address",
                            style: netTextStyle,
                          ),
                          Text(
                            "192.168.1.1",
                            style: netTextStyle,
                          ),
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
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                SectionItem(
                  title: "FAQ",
                  trailing: const Icon(Icons.chevron_right_rounded),
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
            const SizedBox(height: 15),
            CustomButton(
              text: "Delete Device",
              onPressed: () {},
              textColor: Colors.red,
              backgroundColor: Colors.white,
              disableElevation: true,
            ),
          ],
        ),
      ),
    );
  }
}
