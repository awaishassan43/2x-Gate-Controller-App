import 'package:flutter/material.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/components/selector.component.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

/// Selector screen is sort of a wrapper for selector component
class SelectorScreen<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final bool includesNone;
  final bool isTime;
  final String? deviceID;
  final String mapKey;
  final String? relayID;
  final bool isProfileKey;

  const SelectorScreen({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItem,
    this.includesNone = false,
    this.isProfileKey = false,
    required this.mapKey,
    this.isTime = true,
    this.deviceID,
    this.relayID,
  })  : assert((deviceID != null || relayID != null || isProfileKey)),
        super(key: key);

  @override
  State<SelectorScreen<T>> createState() => _SelectorScreenState<T>();
}

class _SelectorScreenState<T> extends State<SelectorScreen<T>> {
  bool isLoading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomSelector<T>(
                  items: widget.items,
                  selectedItem: widget.selectedItem,
                  transformer: widget.isTime
                      ? (T value) {
                          if (value.runtimeType.toString() == "int") {
                            return getTimeString((value as int));
                          } else {
                            return value.toString();
                          }
                        }
                      : null,
                  onSelected: (T? selectedValue) async {
                    try {
                      setState(() {
                        isLoading = true;
                      });

                      if (widget.isProfileKey) {
                        final UserController controller = Provider.of<UserController>(context, listen: false);

                        controller.profile!.updateProfile(widget.mapKey, selectedValue);
                        await controller.updateProfile();

                        showMessage(context, "Profile updated successfully!");
                      } else if (widget.deviceID != null) {
                        final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

                        final Device device = controller.devices[widget.deviceID]!;
                        device.update(widget.mapKey, selectedValue, relayID: widget.relayID);
                        await controller.updateDevice(device);

                        showMessage(context, "Controller updated successfully!");
                      } else {
                        throw "No device ID was provided";
                      }

                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                        error = e.toString();
                      });

                      showMessage(context, e.toString());
                    }
                  },
                ),
              ],
            ),
          ),
          if (isLoading) Loader(message: widget.isProfileKey ? "Updating profile" : "Updating controller"),
        ],
      ),
    );
  }
}
