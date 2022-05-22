import 'package:flutter/material.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/models/profile.model.dart';
import 'package:iot/util/themes.util.dart';
import 'package:provider/provider.dart';

class SharedDevice extends StatelessWidget {
  final ConnectedDevice device;
  const SharedDevice({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.nickName!,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2.5),
              Text(
                Provider.of<DeviceController>(context, listen: false).devices[device.deviceID]!.deviceData.name,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
