import 'package:flutter/material.dart';
import 'package:iot/controllers/device.controller.dart';
import 'package:iot/util/constants.util.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:iot/components/loader.component.dart';
import 'package:http/http.dart' as http;

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  /// return type indicates whether the device is already connected to the required
  /// wifi or not
  Future<bool> enableWifi() async {
    try {
      final bool isEnabled = await WiFiForIoTPlugin.isEnabled();

      if (!isEnabled) {
        await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
        return await enableWifi();
      } else {
        final String? currentSSID = await WiFiForIoTPlugin.getSSID();

        if (currentSSID != null && currentSSID == deviceSSID) {
          /// i.e. device is already connected to the required connection
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sendCreds() async {
    try {
      final Uri url = Uri.parse(deviceURL);
      final http.Response response = await http.post(url);
      final String macAddress = response.body;

      return macAddress;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> connectDevice(BuildContext context) async {
    final DeviceController controller = Provider.of<DeviceController>(context, listen: false);

    try {
      controller.isLoading = true;

      final bool isAlreadyConnected = await enableWifi();
      String macAddress;

      if (isAlreadyConnected) {
        await sendCreds();
      } else {
        final bool isConnected = await WiFiForIoTPlugin.connect(deviceSSID, password: deviceSSID, joinOnce: true, security: NetworkSecurity.WPA);
        if (isConnected) {}
      }

      controller.isLoading = false;
    } catch (e) {
      controller.isLoading = false;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Device"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          IconButton(
            onPressed: () {
              connectDevice(context);
            },
            icon: const Icon(Icons.wifi),
          ),
          Selector<DeviceController, bool>(
            builder: (context, isLoading, _) {
              return isLoading ? const Loader() : Container();
            },
            selector: (context, controller) => controller.isLoading,
          ),
        ],
      ),
    );
  }
}
