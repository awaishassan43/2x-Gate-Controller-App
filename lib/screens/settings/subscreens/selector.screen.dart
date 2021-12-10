import 'package:flutter/material.dart';
import 'package:iot/components/selector.component.dart';
import 'package:iot/controllers/device.controller.dart';
// import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

/// Selector screen is sort of a wrapper for selector component
class SelectorScreen<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomSelector<T>(
                  items: items,
                  selectedItem: selectedItem,
                  transformer: isTime
                      ? (T value) {
                          if (value.runtimeType.toString() == "int") {
                            return '${((value as int) / 60).toStringAsFixed(1)} minutes';
                          } else {
                            return value.toString();
                          }
                        }
                      : null,
                  onSelected: (T? selectedValue) async {
                    if (deviceID != null || relayID != null) {
                      final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

                      try {
                        controller.isLoading = true;
                        final Device device = controller.devices[deviceID]!;
                        device.updateDevice(mapKey, selectedValue, relayID: relayID);
                        await controller.updateDevice(device);

                        showMessage(context, "Controller updated successfully!");

                        Navigator.pop(context);
                      } catch (e) {
                        showMessage(context, e.toString());
                      }

                      controller.isLoading = false;
                    } else {
                      // final UserController controller = Provider.of<UserController>(context, listen: false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
