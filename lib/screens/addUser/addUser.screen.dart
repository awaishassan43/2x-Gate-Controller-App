import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/device.controller.dart';
import '../../enum/route.enum.dart';
import '../../models/device.model.dart';
import '../../util/themes.util.dart';
import 'components/device.component.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, Device> devices = Provider.of<DeviceController>(context).devices;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            /**
                   * Top Button
                   */
            MaterialButton(
              padding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: authPrimaryColor,
              onPressed: () {
                Navigator.pushNamed(context, Screen.scanner);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Scan QR Code"),
                      Text("to add device via QR code"),
                    ],
                  ),
                ],
              ),
            ),
            /**
                   * End of top button
                   */

            const SizedBox(height: 20),

            /**
                   * Sharing section
                   */
            Expanded(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Select a device to share",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...devices.entries
                          .map(
                            (device) => SharableDevice(
                              deviceID: device.key,
                              deviceName: device.value.deviceData.name,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
