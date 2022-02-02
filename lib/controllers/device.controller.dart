import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DeviceController extends ChangeNotifier {
  final DatabaseReference settingsCollection = FirebaseDatabase.instance.ref('/deviceSettings');
  final DatabaseReference commandsCollection = FirebaseDatabase.instance.ref('/deviceCommands');
  final DatabaseReference deviceCollection = FirebaseDatabase.instance.ref('/devices');
  final DatabaseReference logsCollection = FirebaseDatabase.instance.ref('/deviceStateLogs');

  Map<String, dynamic> devices = {};
  bool _isLoading = false;
  String _outputTimeError = '';

  /// Loader setter and getter
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// error setter and getter
  String get outputTimeError => _outputTimeError;
  set outputTimeError(String value) {
    _outputTimeError = value;
    notifyListeners();
  }

  Future<void> loadDevices(BuildContext context) async {
    try {
      final List<String> deviceIDs = Provider.of<UserController>(context).profile!.devices;

      for (String id in deviceIDs) {
        final DataSnapshot deviceData = await deviceCollection.child(id).get();
        final DataSnapshot deviceSettings = await settingsCollection.child(id).get();
        final DataSnapshot deviceCommands = await commandsCollection.child(id).get();
        final DataSnapshot deviceLogs = await logsCollection.child(id).get();

        final Map<String, dynamic> map = {};
        map['data'] = objectToMap(deviceData.value);
        map['settings'] = objectToMap(deviceSettings.value);
        map['commands'] = objectToMap(deviceCommands.value);
        map['logs'] = objectToMap(deviceLogs.value);

        final Device device = Device.fromRawData(map);
        // devices[id] = device;
      }
    } on FirebaseException catch (e) {
      throw Exception("Error occured while loading devices: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load devices: ${e.toString()}");
    }
  }

  Future<void> addDevice(String id, BuildContext context) async {
    try {
      // Send the request to the device to get the device id
      // final Uri url = Uri.parse('https://google.com/' + id);
      // final http.Response response = await http.post(url).timeout(
      //   const Duration(milliseconds: 7500),
      //   onTimeout: () {
      //     throw "Timed out while trying to send credentials to the device";
      //   },
      // );

      // if (response.statusCode >= 300) {
      //   throw "Failed to add the device";
      // }

      final UserController controller = Provider.of<UserController>(context, listen: false);
      await controller.addDevice(id);
    } on FirebaseException catch (e) {
      throw "Error occured while updating the device: ${e.message}";
    } catch (e) {
      throw "Failed to add the device: ${e.toString()}";
    }
  }

  Future<void> updateDevice(Device device) async {
    // try {
    //   // await collection.child(device.id).set(device.toJSON());
    // } on FirebaseException catch (e) {
    //   throw "Error occured while updating the device: ${e.message}";
    // } catch (e) {
    //   throw "Failed to update the device: ${e.toString()}";
    // }
  }

  removeDevices() {
    devices.clear();
  }
}
