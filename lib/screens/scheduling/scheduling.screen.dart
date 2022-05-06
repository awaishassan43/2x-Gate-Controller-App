import 'package:flutter/material.dart';

import '../../components/button.component.dart';
import '../../enum/route.enum.dart';
import '../../models/device.model.dart';
import 'components/schedule.component.dart';

class SchedulingScreen extends StatelessWidget {
  final String relayID;
  final String deviceID;
  final List<Schedule> schedules;
  const SchedulingScreen({
    Key? key,
    required this.deviceID,
    required this.relayID,
    required this.schedules,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /**
             * TOP Section
             */
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: schedules
                      .map((e) => ScheduleComponent(
                            schedule: e,
                          ))
                      .toList(),
                ),
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
              onPressed: () => Navigator.pushNamed(context, Screen.addSchedule, arguments: {
                "relayID": relayID,
                "deviceID": deviceID,
              }),
            ),
          ],
        ),
      ),
    );
  }
}
