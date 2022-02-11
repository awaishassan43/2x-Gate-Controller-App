import 'package:flutter/material.dart';
import '/controllers/device.controller.dart';
import '/models/relay.model.dart';
import 'package:provider/provider.dart';

class EditRelayNameScreen extends StatefulWidget {
  final String deviceID;
  final String relayID;
  const EditRelayNameScreen({
    Key? key,
    required this.deviceID,
    required this.relayID,
  }) : super(key: key);

  @override
  State<EditRelayNameScreen> createState() => _EditRelayNameScreenState();
}

class _EditRelayNameScreenState extends State<EditRelayNameScreen> {
  bool isLoading = false;

  late final TextEditingController name;
  late final DeviceController controller;
  late final Relay relay;

  String formError = '';
  String nameError = '';

  @override
  void initState() {
    super.initState();
    controller = Provider.of<DeviceController>(context, listen: false);
    controller.devices[widget.deviceID]!.deviceSettings.value.toJson();
    name = TextEditingController(text: relay.name);
  }

  bool validateName() {
    if (name.text == "") {
      setState(() {
        nameError = "This field cannot be empty!";
      });

      return false;
    }

    if (nameError != '') {
      setState(() {
        nameError = '';
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Edit relay name"),
    //     centerTitle: true,
    //   ),
    //   body: Stack(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(20.0),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.stretch,
    //           children: [
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
    //                 children: [
    //                   CustomInput(
    //                     label: "Name of the relay",
    //                     icon: Icons.sensors,
    //                     error: nameError,
    //                     controller: name,
    //                   ),
    //                   if (formError != '')
    //                     Padding(
    //                       padding: const EdgeInsets.all(20),
    //                       child: Text(
    //                         formError,
    //                         textAlign: TextAlign.center,
    //                         style: const TextStyle(
    //                           color: Colors.red,
    //                           fontSize: 12,
    //                         ),
    //                       ),
    //                     ),
    //                 ],
    //               ),
    //             ),
    //             CustomButton(
    //               text: "Update name",
    //               onPressed: () async {
    //                 final bool isNameValid = validateName();

    //                 if (!isNameValid) {
    //                   return;
    //                 }

    //                 setState(() {
    //                   isLoading = true;
    //                 });

    //                 final String previousName = relay.name;

    //                 try {
    //                   controller.devices[widget.device.id]!.relays.values.toList().firstWhere((element) => element.id == relay.id).name =
    //                       name.text.trim();
    //                   await controller.updateDevice(controller.devices[widget.device.id]!);

    //                   showMessage(context, "Name updated successfully!");
    //                   Navigator.pop(context);
    //                 } catch (e) {
    //                   setState(() {
    //                     formError = e.toString();
    //                     isLoading = false;
    //                   });

    //                   controller.devices[widget.device.id]!.relays.values.toList().firstWhere((element) => element.id == relay.id).name =
    //                       previousName;
    //                   showMessage(context, "Failed to update the relay name");
    //                 }
    //               },
    //             ),
    //           ],
    //         ),
    //       ),
    //       if (isLoading) const Loader(message: "Updating controller"),
    //     ],
    //   ),
    // );
  }
}
