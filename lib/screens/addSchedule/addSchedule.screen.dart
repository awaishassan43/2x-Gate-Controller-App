import 'package:flutter/material.dart';
import 'package:iot/components/seperator.component.dart';
import 'package:iot/screens/addSchedule/components/day.component.dart';
import 'package:iot/screens/addSchedule/components/heading.component.dart';

import '../../models/device.model.dart';
import '../../util/functions.util.dart';

class AddScheduleScreen extends StatefulWidget {
  final String relayID;
  final String deviceID;
  final Schedule? schedule;
  final int? scheduleIndex;

  const AddScheduleScreen({
    Key? key,
    required this.relayID,
    required this.deviceID,
    this.schedule,
    this.scheduleIndex,
  }) : super(key: key);

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  late bool isEnabled;
  late bool repeat;
  late Map<String, bool> days;
  late DateTime time;

  @override
  void initState() {
    super.initState();

    isEnabled = widget.schedule?.enabled != null ? widget.schedule!.enabled : false;
    repeat = widget.schedule?.repeat != null ? widget.schedule!.repeat : false;
    days = widget.schedule?.days != null ? widget.schedule!.days : createDayMap();
    time = widget.schedule?.executionTime != null ? widget.schedule!.executionTime : DateTime.now();
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

  @override
  Widget build(BuildContext context) {
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
              title: const CustomHeading(heading: "Enabled"),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              height: 1.5,
              color: Colors.grey.withOpacity(0.4),
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
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
                            children:
                                days.entries.map((entry) => DaySelector(day: entry.key, isSelected: entry.value, onSelected: onDayClicked)).toList(),
                          ),
                        ),
                        crossFadeState: repeat ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  ),
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
          ],
        ),
      ),
    );
  }
}
