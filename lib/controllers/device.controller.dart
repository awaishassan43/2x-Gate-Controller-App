import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '/controllers/user.controller.dart';
import '/models/device.model.dart';
import '/util/functions.util.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DeviceController extends ChangeNotifier {
  final DatabaseReference settingsCollection = FirebaseDatabase.instance.ref('/deviceSettings');
  final DatabaseReference commandsCollection = FirebaseDatabase.instance.ref('/deviceCommands');
  final DatabaseReference deviceCollection = FirebaseDatabase.instance.ref('/devices');
  final DatabaseReference logsCollection = FirebaseDatabase.instance.ref('/deviceStateLogs');

  Map<String, Device> devices = {};
  bool _isLoading = false;
  String _outputTimeError = '';

  /// A local variable to keep and control the listeners
  Map<String, List<StreamSubscription>> deviceListeners = {};

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
      print("Running load devices");

      final List<String> deviceIDs = Provider.of<UserController>(context, listen: false).profile!.devices;
      final List<String> devicesToBeRemoved = devices.keys.where((element) => !deviceIDs.contains(element)).toList();

      /// Adding new devices
      for (String id in deviceIDs) {
        if (!devices.containsKey(id) && deviceListeners[id] == null) {
          final DataSnapshot deviceData = await deviceCollection.child(id).get();
          final DataSnapshot deviceSettings = await settingsCollection.child(id).get();
          final DataSnapshot deviceLogs = await logsCollection.child(id).get();
          final DataSnapshot deviceCommands = await commandsCollection.child(id).get();

          final Map<String, dynamic> map = {};
          map['deviceData'] = objectToMap(deviceData.value);
          map['deviceSettings'] = objectToMap(deviceSettings.value);
          map['deviceCommands'] = objectToMap(deviceCommands.value);
          map['deviceStateLogs'] = objectToMap(deviceLogs.value);

          final Device device = Device.fromJson(map);
          devices[id] = device;

          /**
           * Attaching data listener
           */
          deviceListeners[id] = [
            deviceData.ref.onValue.listen((event) {
              devices[id]!.updateWithJSON(deviceData: objectToMap(event.snapshot.value));
              notifyListeners();
            }),

            /**
             * Attaching settings listener
             */
            deviceSettings.ref.onValue.listen((event) {
              devices[id]!.updateWithJSON(deviceSettings: objectToMap(event.snapshot.value));
              notifyListeners();
            }),
          ];
        }
      }

      /// Removing previous devices and cancelling subscriptions
      for (String id in devicesToBeRemoved) {
        devices.remove(id);

        if (deviceListeners.containsKey(id)) {
          for (StreamSubscription listener in deviceListeners[id]!) {
            listener.cancel();
          }
        }
      }
    } on FirebaseException catch (e) {
      throw Exception("Error occured while loading devices: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load devices: ${e.toString()}");
    }
  }

  Future<void> addDevice(String id, BuildContext context) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);

      /// TODO
      /// WARNING ---- not checking for response type
      await http.post(getCloudURL(id));

      /// Create the json data for the device
      final Device device = getEmptyDeviceData(id, controller.getUserID());

      /// Add the device data to firebase
      commandsCollection.child(id).set(device.deviceCommands.toJson());
      deviceCollection.child(id).set(device.deviceData.toJson());
      settingsCollection.child(id).set(device.deviceSettings.toJson());

      // /// Attach device to the user profile
      await controller.addDevice(id);
    } on FirebaseException catch (e) {
      throw "Error occured while updating the device: ${e.message}";
    } catch (e) {
      throw "Failed to add the device: ${e.toString()}";
    }
  }

  Future<void> updateDevice(String id, String collectionKey) async {
    try {
      final Device device = devices[id]!;

      if (collectionKey == "deviceData") {
        await deviceCollection.child(id).set(device.deviceData.toJson());
      } else if (collectionKey == "deviceCommands") {
        await commandsCollection.child(id).set(device.deviceCommands.toJson());
      } else if (collectionKey == "deviceSettings") {
        await settingsCollection.child(id).set(device.deviceSettings.toJson());
      }
    } on FirebaseException catch (e) {
      throw "Error occured while updating the device: ${e.message}";
    } catch (e) {
      throw "Failed to update the device: ${e.toString()}";
    }
  }

  removeDevices() {
    devices.clear();
  }
}
