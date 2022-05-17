import 'package:flutter/material.dart';
import 'package:iot/models/device.model.dart';

class ScheduleComponent extends StatelessWidget {
  final Schedule schedule;
  const ScheduleComponent({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: MaterialButton(
        padding: const EdgeInsets.all(10),
        onPressed: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(
                  Icons.timer,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text("${schedule.hours}:${schedule.minutes}"),
                  Text(schedule.days.entries.where((e) => e.value == true).map((e) => e.key).join(',')),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
