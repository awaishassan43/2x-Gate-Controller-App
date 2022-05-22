import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/access.enum.dart';
import 'package:iot/models/profile.model.dart';
import 'package:iot/screens/addSchedule/components/heading.component.dart';
import 'package:provider/provider.dart';
import '../../util/functions.util.dart';

class EditSharedDevice extends StatefulWidget {
  final String accessID;
  const EditSharedDevice({
    Key? key,
    required this.accessID,
  }) : super(key: key);

  @override
  State<EditSharedDevice> createState() => _EditSharedDeviceState();
}

class _EditSharedDeviceState extends State<EditSharedDevice> {
  bool isLoading = false;
  late ConnectedDevice device;
  late final TextEditingController textEditingController;
  late AccessType type;

  @override
  void initState() {
    super.initState();

    final UserController controller = Provider.of<UserController>(context, listen: false);
    device = controller.profile!.accessesProvidedToUsers.firstWhere((element) => element.id == widget.accessID);

    textEditingController = TextEditingController(text: device.nickName);
    type = device.accessType;
  }

  Future<void> updateAccess(BuildContext context) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);
      await controller.updateDeviceAccess(
        ConnectedDevice(id: device.id, deviceID: device.id, accessType: type, userID: device.userID),
      );

      showMessage(context, "Updated successfully!");
      Navigator.pop(context);
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

  Future<void> revokeAccess(BuildContext context) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);
      await controller.revokeAccess(device.id);

      showMessage(context, "Access revoked successfully!");
      Navigator.pop(context);
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Shared Device"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: const CustomHeading(heading: "Device Name"),
                  trailing: Text(Provider.of<DeviceController>(context, listen: false).devices[device.deviceID]!.deviceData.name),
                ),
                CustomInput(label: "NickName", controller: textEditingController),
                ListTile(
                  title: const CustomHeading(heading: "Access Type"),
                  trailing: DropdownButton<AccessType>(
                    value: type,
                    items: AccessType.values
                        .map(
                          (accessType) => DropdownMenuItem(
                            child: Text(accessType.value.capitalize()),
                            value: accessType,
                          ),
                        )
                        .toList(),
                    onChanged: (accessType) {
                      if (accessType == null) {
                        return;
                      }

                      setState(() {
                        type = accessType;
                      });
                    },
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text: "Update Access",
                  backgroundColor: Colors.white,
                  disableElevation: true,
                  onPressed: () => updateAccess(context),
                ),
                const SizedBox(height: 7.5),
                CustomButton(
                  text: "Revoke Access",
                  backgroundColor: Colors.white,
                  disableElevation: true,
                  textColor: Colors.red,
                  onPressed: () => revokeAccess(context),
                ),
              ],
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
