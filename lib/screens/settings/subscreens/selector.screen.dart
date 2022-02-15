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
  final String mapKey;
  final String? relayID;
  final String? deviceID;
  final bool updateProfile;
  final bool updateDeviceSettings;

  const SelectorScreen({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.mapKey,
    this.relayID,
    this.includesNone = false,
    this.deviceID,
    this.isTime = true,
    this.updateProfile = false,
    this.updateDeviceSettings = false,
  })  : assert(updateProfile || updateDeviceSettings, "One of these must be true"),
        assert(
          (!updateProfile && updateDeviceSettings) || (updateProfile && !updateDeviceSettings),
          "updateProfile or updateDeviceSettings - Only one must be true at a time",
        ),
        assert(
          !updateDeviceSettings || (updateDeviceSettings && deviceID != null),
          "Either provide a device id or set updateDeviceSettings to false",
        ),
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

                      if (widget.updateProfile) {
                        final UserController controller = Provider.of<UserController>(context, listen: false);

                        controller.profile!.updateProfile(widget.mapKey, selectedValue);
                        await controller.updateProfile();

                        showMessage(context, "Profile updated successfully!");
                      } else if (widget.updateDeviceSettings && widget.deviceID != null) {
                        final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

                        final Map<String, dynamic> mappedData = controller.devices[widget.deviceID]!.deviceSettings.toJson();

                        if (widget.relayID != null) {
                          mappedData['value'][widget.relayID][widget.mapKey] = selectedValue;
                        } else {
                          mappedData['value'][widget.mapKey] = selectedValue;
                        }

                        controller.devices[widget.deviceID!]!.updateWithJSON(deviceSettings: mappedData);
                        await controller.updateDevice(widget.deviceID!, 'deviceSettings');
                        showMessage(context, "Controller updated successfully!");
                      } else {
                        throw "No device ID was provided";
                      }

                      setState(() {
                        isLoading = false;
                      });

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
          if (isLoading) Loader(message: widget.updateProfile ? "Updating profile" : "Updating controller"),
        ],
      ),
    );
  }
}
