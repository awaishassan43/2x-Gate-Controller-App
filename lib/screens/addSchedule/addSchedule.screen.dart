import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/util/themes.util.dart';
import 'package:provider/provider.dart';

import '../../controllers/user.controller.dart';
import '../../models/device.model.dart';
import '../../util/functions.util.dart';
import 'components/day.component.dart';
import 'components/heading.component.dart';

class AddScheduleScreen extends StatefulWidget {
  final String relayID;
  final String deviceID;
  final int? scheduleIndex;
  final int length;

  const AddScheduleScreen({
    Key? key,
    required this.relayID,
    required this.deviceID,
    required this.length,
    this.scheduleIndex,
  }) : super(key: key);

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  late bool isEnabled;
  late bool repeat;
  late Map<String, bool> days;
  late int hours;
  late int minutes;
  late String actionToPerform;

  /// List of avaiable commands and the selected command
  final List<String> commands = ["OPEN", "CLOSE"];

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic> deviceSettings =
        Provider.of<DeviceController>(context, listen: false).devices[widget.deviceID]!.deviceSettings.toJson();
    final List<Map<String, dynamic>> mappedSchedules = deviceSettings['value'][widget.relayID]['schedules'] ?? [];

    Schedule? schedule;

    if (widget.scheduleIndex != null) {
      schedule = Schedule.fromJson(mappedSchedules[widget.scheduleIndex!]);
    }

    isEnabled = schedule?.enabled != null ? schedule!.enabled : false;
    repeat = schedule?.repeat != null ? schedule!.repeat : false;
    days = schedule?.days != null ? schedule!.days : createDayMap();
    hours = schedule?.hours != null ? schedule!.hours : DateTime.now().hour;
    minutes = schedule?.minutes != null ? schedule!.minutes : DateTime.now().minute;
    actionToPerform = schedule?.actionToPerform != null ? schedule!.actionToPerform : commands[0];
  }

  void onDayClicked(String day, bool isSelected) {
    final Map<String, bool> newDays = {...days};

    /**
     * isSelected refers to whether the day is already selected or not
     * if it is true, i.e. it is already selected, then toggle it to false else set it to true
     */
    newDays[day] = !isSelected;

    setState(() {
      days = newDays;
    });
  }

  Future<void> addSchedule(BuildContext context) async {
    try {
      /**
       * Getting the relevant device and the device settings.... and converting it to json
       */
      final DeviceController controller = Provider.of<DeviceController>(context, listen: false);
      final Map<String, dynamic> deviceSettings = controller.devices[widget.deviceID]!.deviceSettings.toJson();

      /**
       * Creating the mapped data .... using mappedData because it simplifies the relayID usage... because in case of class manipulation,
       * using the relayID is a bit difficult...
       */
      final Schedule newSchedule = Schedule(
        index: widget.scheduleIndex != null ? widget.scheduleIndex! : widget.length,
        enabled: isEnabled,
        repeat: repeat,
        days: days,
        hours: hours,
        minutes: minutes,
        actionToPerform: actionToPerform,
      );

      final Map<String, dynamic> mappedSchedule = newSchedule.toJson();

      /**
       * If an index is provided, i.e. it is not null,
       * then update the current schedule, otherwise create a new one
       */
      if (widget.scheduleIndex != null) {
        deviceSettings['value'][widget.relayID]['schedules'][widget.scheduleIndex!] = mappedSchedule;
      } else {
        deviceSettings['value'][widget.relayID]['schedules'] = [...(deviceSettings['value'][widget.relayID]['schedules'] ?? []), mappedSchedule];
      }

      // Update the device
      controller.devices[widget.deviceID]!.updateWithJSON(deviceSettings: deviceSettings);
      await controller.updateDevice(widget.deviceID, "deviceSettings");

      showMessage(context, widget.scheduleIndex != null ? "Schedule update successfully" : "Schedule created successfully");

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error occured while adding/updating a schedule: ${e.toString()}");
      showMessage(context, widget.scheduleIndex != null ? "Failed to update the schedule" : "Failed to add a schedule");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool is24Hours = Provider.of<UserController>(context, listen: false).profile!.is24Hours;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a new schedule"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              value: isEnabled,
              onChanged: (value) {
                setState(() {
                  isEnabled = value;
                });
              },
              title: const CustomHeading(heading: "Switch"),
            ),
            /**
             * Seperator
             */
            Container(
              margin: const EdgeInsets.all(20),
              height: 1.5,
              color: Colors.grey.withOpacity(0.4),
            ),
            /**
             * End of seperator
             */

            Stack(
              children: [
                Column(
                  children: [
                    ListTile(
                      title: const CustomHeading(heading: "Schedule Time"),
                      trailing: MaterialButton(
                        color: backgroundColor,
                        onPressed: () async {
                          final TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: hours, minute: minutes),
                          );

                          if (selectedTime == null) {
                            return;
                          }

                          setState(() {
                            hours = selectedTime.hour;
                            minutes = selectedTime.minute;
                          });
                        },
                        child: Text(
                          formatTime(is24Hours, hours, minutes),
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const CustomHeading(heading: "Action"),
                      trailing: DropdownButton<String>(
                        value: actionToPerform,
                        items: commands.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                        onChanged: (item) {
                          if (item == null) {
                            return;
                          }

                          setState(() {
                            actionToPerform = item;
                          });
                        },
                      ),
                    ),
                    SwitchListTile(
                      value: repeat,
                      enableFeedback: isEnabled,
                      onChanged: (value) {
                        setState(() {
                          repeat = value;
                        });
                      },
                      title: const CustomHeading(heading: "Repeat"),
                    ),
                    AnimatedCrossFade(
                      firstChild: Container(),
                      secondChild: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Column(
                          children: days.entries
                              .map((entry) => DaySelector(
                                    day: entry.key,
                                    isSelected: entry.value,
                                    onSelected: onDayClicked,
                                  ))
                              .toList(),
                        ),
                      ),
                      crossFadeState: repeat ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                  ],
                ),
                if (!isEnabled)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: widget.scheduleIndex != null ? "Save Changes" : "Add Schedule",
              onPressed: () => addSchedule(context),
            ),
          ],
        ),
      ),
    );
  }
}
