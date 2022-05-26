import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

import '../../components/button.component.dart';
import '../../enum/route.enum.dart';
import '../../models/device.model.dart';
import 'components/schedule.component.dart';

class SchedulingScreen extends StatefulWidget {
  final String relayID;
  final String deviceID;
  const SchedulingScreen({
    Key? key,
    required this.deviceID,
    required this.relayID,
  }) : super(key: key);

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  /// isLoading - boolean - whether to hide or show the loading indicator
  bool isLoading = false;

  Future<void> deleteSchedule(int scheduleIndex) async {
    setState(() {
      isLoading = true;
    });

    try {
      /**
       * Getting the device controller instance
       */
      final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

      /**
       * Getting the device settings json data
       * it is important to note that we're getting the JSON data because it makes it easy to handle variables like
       * relay id.... as well as any other specific keys that we need to update...
       */
      final Map<String, dynamic> deviceSettings = controller.devices[widget.deviceID]!.deviceSettings.toJson();

      /**
       * Removing the schedule and updating the device using JSON data
       */
      (deviceSettings['value'][widget.relayID]['schedules'] as List<Map<String, dynamic>>).removeAt(scheduleIndex);
      controller.devices[widget.deviceID]!.updateWithJSON(deviceSettings: deviceSettings);

      /**
       * Update the device data
       */
      controller.updateDevice(widget.deviceID, "deviceSettings");

      showMessage(context, "Schedule deleted successfully!");
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to remove the schedule: ${e.message}");
      showMessage(context, e.message ?? "Something went wrong while trying to load devices");
    } catch (e) {
      debugPrint("Generic Exception: Failed to remove the schedule: ${e.toString()}");
      throw "Failed to load devices: ${e.toString()}";
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /**
                 * TOP Section
                 */
                Expanded(
                  child: SingleChildScrollView(
                    child: Selector<DeviceController, List<Schedule>?>(
                        selector: (context, controller) => widget.relayID == "Relay1"
                            ? controller.devices[widget.deviceID]!.deviceSettings.value.relay1.schedules
                            : controller.devices[widget.deviceID]!.deviceSettings.value.relay2.schedules,
                        builder: (context, schedules, _) {
                          return Column(
                            children: (schedules ?? [])
                                .asMap()
                                .entries
                                .map((entry) => ScheduleComponent(
                                      schedule: entry.value,
                                      onClick: () {
                                        Navigator.pushNamed(context, Screen.addSchedule, arguments: {
                                          "scheduleIndex": entry.key,
                                          "relayID": widget.relayID,
                                          "deviceID": widget.deviceID,
                                        });
                                      },
                                      onDelete: () => deleteSchedule(entry.key),
                                    ))
                                .toList(),
                          );
                        }),
                  ),
                ),
                /**
                 * END of TOP section
                 */

                /**
                 * Bottom button
                 */
                CustomButton(
                  text: "Add New Schedule",
                  onPressed: () => Navigator.pushNamed(
                    context,
                    Screen.addSchedule,
                    arguments: {
                      "relayID": widget.relayID,
                      "deviceID": widget.deviceID,
                    },
                  ),
                ),
              ],
            ),
            if (isLoading) const Loader(),
          ],
        ),
      ),
    );
  }
}
