import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user.controller.dart';
import '../../enum/access.enum.dart';
import '../../models/profile.model.dart';
import 'components/device.component.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Devices"),
        centerTitle: true,
      ),
      body: Selector<UserController, List<ConnectedDevice>>(
        selector: (context, controller) =>

            /// Only show the devivces that have accessType of family and the access is being provided by the current user
            controller.profile!.accessesProvidedToUsers
                .where((element) => element.accessType == AccessType.family && element.accessProvidedBy == controller.getUserID())
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
