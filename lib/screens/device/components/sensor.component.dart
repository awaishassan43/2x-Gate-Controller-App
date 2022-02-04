import 'package:flutter/material.dart';
import 'package:iot/util/themes.util.dart';

class DeviceSensor extends StatelessWidget {
  final String sensorName;
  final dynamic value;
  final String? unit;
  final bool showDegrees;
  final bool showPercent;
  final String icon;
  const DeviceSensor({
    Key? key,
    required this.sensorName,
    required this.value,
    this.showDegrees = false,
    this.unit,
    this.showPercent = false,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sensorName,
              style: const TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Image.asset(
                  icon,
                  height: 24,
                  width: 24,
                ),
                const SizedBox(
                  width: 10,
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: "${value.toString()}${showPercent ? "%" : ""}",
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 20,
                        ),
                      ),
                      if (showDegrees) const TextSpan(text: "\u00b0"),
                      if (unit != null)
                        TextSpan(
                          text: unit,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                    ],
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
