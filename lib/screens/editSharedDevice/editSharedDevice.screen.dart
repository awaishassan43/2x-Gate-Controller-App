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
  /// isLoading - boolean - controls whether to show or hide the loading indicator
  bool isLoading = false;

  /// device - ConnectedDevice object - maintains the deviceAccess data
  late ConnectedDevice device;

  /// textEditingController - TextEditingController - controls the nickName editing field
  late final TextEditingController textEditingController;

  /// type - AccessType enumerator - controls editing the access type that the user has shared to other device
  late AccessType type;

  @override
  void initState() {
    super.initState();

    /**
     * Get the UserController reference
     */
    final UserController controller = Provider.of<UserController>(context, listen: false);

    // Get the respective deviceAccess object based on the accessID provided to the screen as accessID argument
    device = controller.profile!.accessesProvidedToUsers.firstWhere((element) => element.id == widget.accessID);

    // Fill in the data in the nickname field and the access type dropdown field
    textEditingController = TextEditingController(text: device.nickName);
    type = device.accessType;
  }

  /// Update the device access object
  Future<void> updateAccess(BuildContext context) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);

      await controller.updateDeviceAccess(
        ConnectedDevice(
          id: device.id,
          deviceID: device.deviceID,
          nickName: textEditingController.text,
          accessType: type,
          userID: device.userID,
          key: device.key,
          accessProvidedBy: device.accessProvidedBy,
        ),
      );

      showMessage(context, "Updated successfully!");
      Navigator.pop(context);
    } catch (e) {
      showMessage(context, e.toString());
    }
  }

  List<AccessType> getShareableAccesses() {
    final AccessType hasAccessType = device.accessType;

    if (hasAccessType == AccessType.owner) {
      return [AccessType.guest, AccessType.family];
    } else if (hasAccessType == AccessType.family) {
      return [AccessType.guest, AccessType.family];
    } else {
      return [AccessType.guest];
    }
  }

  /// This method revokes the access to a device that the current user has provided to other users
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
                ListTile(
                  title: const CustomHeading(heading: "Status"),
                  trailing: device.key != null
                      ? const Text(
                          "Pending",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        )
                      : const Text(
                          "Active",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomHeading(heading: "Nickname"),
                      const SizedBox(height: 5),
                      CustomInput(label: "NickName", controller: textEditingController),
                    ],
                  ),
                ),
                ListTile(
                  title: const CustomHeading(heading: "Access Type"),
                  trailing: DropdownButton<AccessType>(
                    value: type,
                    items: getShareableAccesses()
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
