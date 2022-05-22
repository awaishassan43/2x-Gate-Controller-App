import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/profile.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

import '../../enum/route.enum.dart';

class DeviceAcceptingScreen extends StatefulWidget {
  const DeviceAcceptingScreen({Key? key}) : super(key: key);

  @override
  State<DeviceAcceptingScreen> createState() => _DeviceAcceptingScreenState();
}

class _DeviceAcceptingScreenState extends State<DeviceAcceptingScreen> {
  late Future<void> attachDevice;

  @override
  void initState() {
    super.initState();
    attachDevice = attachingDevice(context);
  }

  Future<void> attachingDevice(BuildContext context) async {
    try {
      final AppLinks _appLinks = AppLinks();
      final Uri? uri = await _appLinks.getInitialAppLink();

      final String? sharingKey = uri?.queryParameters["key"];

      if (sharingKey == null) {
        showMessage(context, "Failed to get the sharable link");
        Navigator.pushNamed(context, Screen.dashboard);

        return;
      }

      final UserController controller = Provider.of<UserController>(context, listen: false);

      final List<ConnectedDevice> accesses = controller.profile!.accessesProvidedToUsers;
      final ConnectedDevice device = accesses.firstWhere((access) => access.key == sharingKey);

      if (device.key == null) {
        throw "Cannot add this device - Please ask the owner to share the link again";
      }

      controller.addRemoteDevice(device.key!);
    } catch (e) {
      showMessage(context, "Failed to add the device");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: attachDevice,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Loader(message: "Adding new device");
            }

            if (snapshot.hasError) {
              return ErrorMessage(message: snapshot.error!.toString());
            }

            return Column(
              children: const [
                Text("Device added successfully!"),
              ],
            );
          },
        ),
      ],
    );
  }
}
