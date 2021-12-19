import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/models/device.model.dart';
import 'package:provider/provider.dart';

class DeviceController extends ChangeNotifier {
  DatabaseReference collection = FirebaseDatabase.instance.ref('/');

  Map<String, Device> devices = {};
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

  void updateReference() {
    final String userID = FirebaseAuth.instance.currentUser!.uid;
    collection = collection.child('$userID/devices/');
  }

  Future<void> loadDevices() async {
    try {
      updateReference();
      final DataSnapshot data = await collection.get();

      // for (String deviceID in deviceIDs) {
      //   final DocumentSnapshot<Map<String, dynamic>> document = await collection.doc(deviceID).get();

      //   final Map<String, dynamic>? deviceData = document.data();

      //   if (deviceData == null) {
      //     throw "Device data does not exist";
      //   }

      //   deviceData['id'] = deviceID;
      //   final Device device = deviceWithData(deviceData, document.reference);

      //   devices[deviceID] = device;
      // }
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

      final DatabaseReference ref = collection.child(deviceID);
      await ref.set(deviceData);

      final Device newDevice = Device.fromMap(device.toJSON(), stream: ref.onValue);
      devices[deviceID] = newDevice;

      notifyListeners();
    } on FirebaseException catch (e) {
      throw Exception("Error occured while adding the device: ${e.message}");
    } catch (e) {
      throw Exception("Failed to add the device: ${e.toString()}");
    }
  }

  Future<void> updateDevice(Device device) async {
    try {
      // await collection.doc(device.id).set(device.toJSON());
    } on FirebaseException catch (e) {
      throw "Error occured while updating the device: ${e.message}";
    } catch (e) {
      throw "Failed to update the device: ${e.toString()}";
    }
  }

  removeDevice(String deviceID, BuildContext context) async {
    try {
      // await collection.doc(deviceID).delete();
      // devices.remove(deviceID);

      // await Provider.of<UserController>(context, listen: false).unlinkDeviceFromUser(deviceID);

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
