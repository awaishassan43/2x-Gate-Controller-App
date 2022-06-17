import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/util/themes.util.dart';
import 'package:provider/provider.dart';
import '../../../util/functions.util.dart';

class ScheduleComponent extends StatelessWidget {
  final Schedule schedule;
  final void Function() onClick;
  final void Function() onDelete;
  const ScheduleComponent({
    Key? key,
    required this.schedule,
    required this.onClick,
    required this.onDelete,
  }) : super(key: key);

  String getDays() {
    final List<String> days = schedule.days.entries.where((e) => e.value == true).map((e) => e.key.substring(0, 3).capitalize()).toList();

    return days.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final bool is24Hours = Provider.of<UserController>(context, listen: false).profile!.is24Hours;

    return Card(
      margin: const EdgeInsets.only(bottom: 7.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 2.5,
      child: MaterialButton(
        padding: const EdgeInsets.all(10),
        onPressed: onClick,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        formatTime(is24Hours, schedule.hours, schedule.minutes),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.5,
                          color: textColor,
                        ),
                      ),
                      if (!schedule.enabled) ...[
                        const SizedBox(width: 10),
                        const Text(
                          "Disabled",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 3.5),
                  Text(
                    schedule.repeat ? getDays() : "Once",
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    "Switch: ${schedule.actionToPerform}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
