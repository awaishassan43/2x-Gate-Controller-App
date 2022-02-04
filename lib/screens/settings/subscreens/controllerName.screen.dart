import 'package:flutter/material.dart';
import '/components/button.component.dart';
import '/components/input.component.dart';
import '/components/loader.component.dart';
import '/controllers/device.controller.dart';
import '/models/device.model.dart';
import '/util/functions.util.dart';
import 'package:provider/provider.dart';

class EditControllerNameScreen extends StatefulWidget {
  final Device device;
  const EditControllerNameScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<EditControllerNameScreen> createState() => _EditControllerNameScreenState();
}

class _EditControllerNameScreenState extends State<EditControllerNameScreen> {
  bool isLoading = false;

  late final TextEditingController name;
  late final DeviceController controller;

  String formError = '';
  String nameError = '';

  // @override
  // void initState() {
  //   super.initState();
  //   name = TextEditingController(text: widget.device.name);
  //   controller = Provider.of<DeviceController>(context, listen: false);
  // }

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
    //     title: const Text("Edit controller name"),
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
    //                     label: "Name of the controller",
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

    //                 final String previousName = widget.device.name;

    //                 try {
    //                   controller.devices[widget.device.id]!.name = name.text.trim();
    //                   await controller.updateDevice(controller.devices[widget.device.id]!);

    //                   showMessage(context, "Name updated successfully!");
    //                   Navigator.pop(context);
    //                 } catch (e) {
    //                   setState(() {
    //                     formError = e.toString();
    //                     isLoading = false;
    //                   });

    //                   controller.devices[widget.device.id]!.name = previousName;
    //                   showMessage(context, "Failed to update the controller name");
    //                 }
    //               },
    //             ),
    //           ],
    //         ),
    //       ),
    //       if (isLoading) const Loader(message: "Updating controller "),
    //     ],
    //   ),
    // );
  }
}
