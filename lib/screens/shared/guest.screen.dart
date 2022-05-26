import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/enum/access.enum.dart';
import 'package:iot/models/profile.model.dart';
import 'package:iot/screens/shared/components/device.component.dart';
import 'package:provider/provider.dart';

class GuestsScreen extends StatelessWidget {
  const GuestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Devices"),
        centerTitle: true,
      ),
      body: Selector<UserController, List<ConnectedDevice>>(
        selector: (context, controller) =>

            /// Only show the devivces that have accessType of family and the access is being provided by the current user
            controller.profile!.accessesProvidedToUsers
                .where((element) => element.accessType == AccessType.guest && element.accessProvidedBy == controller.getUserID())
                .toList(),
        builder: (context, guests, _) {
          return ListView.builder(
            itemCount: guests.length,
            itemBuilder: (context, index) {
              final ConnectedDevice device = guests[index];
              return SharedDevice(device: device);
            },
          );
        },
      ),
    );
  }
}
