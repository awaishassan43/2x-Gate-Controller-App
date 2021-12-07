import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:provider/provider.dart';

class DeviceController extends ChangeNotifier {
  final collection = FirebaseFirestore.instance.collection('devices');
  Map<String, Device> devices = {};

  Future<void> loadDevices({required List<String> deviceIDs}) async {
    try {
      for (String deviceID in deviceIDs) {
        final DocumentSnapshot<Map<String, dynamic>> document = await collection.doc(deviceID).get();

        final Map<String, dynamic>? deviceData = document.data();

        if (deviceData == null) {
          throw "Device data does not exist";
        }

        deviceData['id'] = deviceID;
        final Device device = deviceWithData(deviceData, document.reference);

        devices[deviceID] = device;
      }
    } on FirebaseException catch (e) {
      throw Exception("Error occured while loading devices: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load devices: ${e.toString()}");
    }
  }

  Future<void> addDevice(Device device, BuildContext context) async {
    try {
      final String deviceID = device.id;
      final Map<String, dynamic> deviceData = device.toJSON();
      deviceData.remove('id');

      final DocumentReference<Map<String, dynamic>> document = collection.doc(deviceID);
      await document.set(deviceData);

      final Device newDevice = deviceWithData(deviceData, document);
      devices[deviceID] = newDevice;

      await Provider.of<UserController>(context, listen: false).linkDeviceToUser(document.id);
      notifyListeners();
    } on FirebaseException catch (e) {
      throw Exception("Error occured while adding the device: ${e.message}");
    } catch (e) {
      throw Exception("Failed to add the device: ${e.toString()}");
    }
  }

  Device deviceWithData(Map<String, dynamic> data, DocumentReference<Map<String, dynamic>> document) {
    data['id'] = document.id;
    return Device.fromMap(data, ref: document);
  }

  removeDevice(String deviceID, BuildContext context) async {
    try {
      await collection.doc(deviceID).delete();
      devices.remove(deviceID);

      await Provider.of<UserController>(context, listen: false).unlinkDeviceFromUser(deviceID);

      notifyListeners();
    } on FirebaseException catch (e) {
      throw "Error occured while removing the device: ${e.message}";
    } catch (e) {
      throw Exception("Failed to remove the device: ${e.toString()}");
    }
  }

  removeDevices() {
    devices.clear();
  }
}
