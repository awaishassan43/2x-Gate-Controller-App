import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:provider/provider.dart';

class DeviceController extends ChangeNotifier {
  final collection = FirebaseFirestore.instance.collection('devices');
  Map<String, Stream<DocumentSnapshot<Map<String, dynamic>>>> deviceStreams = {};
  Map<String, Map<String, dynamic>> devices = {};

  Future<void> loadDevices({required List<String> deviceIDs}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> deviceCollection = await collection.get();

      if (deviceCollection.docs.isNotEmpty) {
        final Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> filteredDevices =
            deviceCollection.docs.where((element) => deviceIDs.contains(element.id));

        for (var element in filteredDevices) {
          deviceStreams[element.id] = element.reference.snapshots();
          devices[element.id] = element.data();
        }
      }
    } on FirebaseException catch (e) {
      throw Exception("Error occured while loading devices: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load devices: ${e.toString()}");
    }
  }

  Future<void> addDevice(Map<String, dynamic> device, BuildContext context) async {
    try {
      final DocumentReference<Map<String, dynamic>> document = await collection.add(device);
      deviceStreams[document.id] = document.snapshots();
      devices[document.id] = device;
      device["id"] = document.id;

      await Provider.of<UserController>(context, listen: false).linkDeviceToUser(document.id);

      notifyListeners();
    } on FirebaseException catch (e) {
      throw Exception("Error occured while adding the device: ${e.message}");
    } catch (e) {
      throw Exception("Failed to add the device: ${e.toString()}");
    }
  }

  removeDevice(String deviceID, BuildContext context) async {
    try {
      await collection.doc(deviceID).delete();
      deviceStreams.remove(deviceID);
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
    deviceStreams.clear();
  }
}
