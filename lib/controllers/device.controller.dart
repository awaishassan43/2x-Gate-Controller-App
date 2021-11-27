import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:iot/models/device.model.dart';

class DeviceController extends ChangeNotifier {
  String? _message;
  String? _deviceMAC;
  bool _isLoading = false;
  final List<Device> devices = [];

  loadDevices({required String userID}) async {
    try {
      final CollectionReference remoteDevices = FirebaseFirestore.instance.collection('devices');

      final QuerySnapshot<Object?> snapshot = await remoteDevices.where('userID', isEqualTo: userID).get();
      final List<QueryDocumentSnapshot<Object?>> documents = snapshot.docs;

      if (documents.isNotEmpty) {
        for (QueryDocumentSnapshot<Object?> document in documents) {
          if (!document.exists) {
            return;
          }

          document.reference.snapshots().listen((event) {
            print("Device updated: ${event.toString()}");
          });

          print("Initial device data: ${document.reference.collection('relays').get()}");
          print(await document.reference.collection('relays').get());
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// message getter and setter
  String? get message => _message;
  set message(String? message) {
    _message = message;
    notifyListeners();
  }

  /// isLoading getter and setter
  bool get isLoading => _isLoading;
  set isLoading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  /// macaddress getter and setter
  String? get deviceMAC => _deviceMAC;
  set deviceMAC(String? value) {
    _deviceMAC = value;
    notifyListeners();
  }
}
