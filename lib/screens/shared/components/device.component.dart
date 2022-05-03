import 'package:flutter/material.dart';

import '../../../enum/route.enum.dart';

class SharedDevice extends StatelessWidget {
  final String deviceID;
  final String deviceName;
  const SharedDevice({
    Key? key,
    required this.deviceID,
    required this.deviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.pushNamed(context, Screen.sharing, arguments: {
        "id": deviceID,
        "name": deviceName,
      }),
      padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 12.5),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.5),
              ),
              child: const Center(
                child: Icon(Icons.device_hub),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(deviceName),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 28,
          ),
        ],
      ),
    );
  }
}
