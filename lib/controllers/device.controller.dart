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
  /// Reference to the deviceSettings database collection
  /// This reference helps in retreiving and updating the respective device settings
  final DatabaseReference settingsCollection = FirebaseDatabase.instance.ref('/deviceSettings');

  /// Reference to the deviceComands collection
  /// This reference helps in sending commands to the device, i.e. to open and close the door and stuff
  final DatabaseReference commandsCollection = FirebaseDatabase.instance.ref('/deviceCommands');

  /// Reference to the devices collection
  /// This reference helps in retreiving and update the device data, i.e. name, door status, online
  /// status, and a couple other things
  final DatabaseReference deviceCollection = FirebaseDatabase.instance.ref('/devices');

  /// Reference to the deviceStateLogs collection
  /// This reference isn't being used yet
  final DatabaseReference logsCollection = FirebaseDatabase.instance.ref('/deviceStateLogs');

  /// 1. A map of device id to the respective device objects
  /// 2. A map of device id with the respective listener from each of the references mentioned above
  /// The deviceListeners map helps in keeping the record of the listeners and then cancelling the
  /// subscription when the user logs out
  Map<String, Device> devices = {};
  Map<String, List<StreamSubscription>> deviceListeners = {};

  /// _isLoading property with getter and setter to control the loading indicator
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// loadDevices Method
  /// This method is responsible for retreiving the list of devices from the database based
  /// on the devices in the profile object provided by the UserController
  /// It also attaches the listeners and adds them to the deviceListeners map, as mentioned above
  Future<void> loadDevices(BuildContext context) async {
    try {
      /**
       * Get the list of devices ids from the user profile
       */
      final List<String>? deviceIDs = Provider.of<UserController>(context, listen: false).profile?.devices.map((e) => e.deviceID).toList();

      if (deviceIDs == null) {
        return;
      }

      /**
       * Since the loadDevices method is called whenever a device is added or removed in the database, this line checks
       * which of the devices already present in the devices map, doesn't exist in the database anymore, so it adds the
       * ids to the devicesToBeRemoved list which gets handled below
       */
      final List<String> devicesToBeRemoved = devices.keys.where((element) => !deviceIDs.contains(element)).toList();

      /// Adding new devices
      for (String id in deviceIDs) {
        /**
         * If the device id is already present and the listeners are already attached to a particular device id, then leave it as
         * it is... otherwise proceed to the if block
         */
        if (!devices.containsKey(id) && deviceListeners[id] == null) {
          /**
           * Get the data from the respective collection
           */
          final DataSnapshot deviceData = await deviceCollection.child(id).get();
          final DataSnapshot deviceSettings = await settingsCollection.child(id).get();
          final DataSnapshot deviceLogs = await logsCollection.child(id).get();
          final DataSnapshot deviceCommands = await commandsCollection.child(id).get();

          /**
           * Convert each of the object retreived to a map, and add to a local variable
           */
          final Map<String, dynamic> map = {};
          map['deviceData'] = objectToMap(deviceData.value);
          map['deviceSettings'] = objectToMap(deviceSettings.value);
          map['deviceCommands'] = objectToMap(deviceCommands.value);
          map['deviceStateLogs'] = objectToMap(deviceLogs.value);

          /**
           * Generate device class using the mapped data and add that to the devices map based on the device id
           * Map.from helps in preventing the direct mutation of the devices map
           */
          final Device device = Device.fromJson(map);
          final Map<String, Device> deviceList = Map.from(devices);
          deviceList[id] = device;

          devices = deviceList;

          /**
           * Attaching data listener
           * Since we don't need to listen to deviceCommands reference, so leaving it
           * Same goes for deviceLogs reference....
           */
          final Map<String, List<StreamSubscription<dynamic>>> listenersList = Map.from(deviceListeners);
          listenersList[id] = [
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

          deviceListeners = listenersList;
          notifyListeners();
        }
      }

      /// Removing previous devices and cancelling subscriptions
      for (String id in devicesToBeRemoved) {
        /**
         * Copy the devices map to a new variable to prevent direct mutation of the state
         * and remove the device from the devices map
         */
        final Map<String, Device> deviceList = Map.from(devices);
        deviceList.remove(id);

        devices = deviceList;

        /**
         * Check if the deviceListeners map contains the device id
         * and if it exists, then loop over the list of streamsubscriptions to cancel them
         */
        if (deviceListeners.containsKey(id)) {
          for (StreamSubscription listener in deviceListeners[id]!) {
            await listener.cancel();
          }

          /**
           * Update the deviceListeners property
           */
          final Map<String, List<StreamSubscription<dynamic>>> listenersList = Map.from(deviceListeners);
          listenersList.remove(id);
          deviceListeners = listenersList;
        }

        notifyListeners();
      }
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to load devices: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to load devices";
    } catch (e) {
      debugPrint("Generic Exception: Failed to load devices: ${e.toString()}");
      throw "Failed to load devices: ${e.toString()}";
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
      await controller.addDevice(id, forSelf: true);
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to add device: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to add a device";
    } catch (e) {
      debugPrint("Generic Exception: Failed to add device: ${e.toString()}");
      throw "Failed to attach the device to user: ${e.toString()}";
    }
  }

  /// updateDevices method
  /// This method takes in the device id, and a collection key to update the respective device data
  /// in the respective collection
  Future<void> updateDevice(String id, String collectionKey) async {
    try {
      /**
       * Get the existing device data from the devices map
       */
      final Device device = devices[id]!;

      /**
       * Update the respective reference based on the collection key...
       * 1. deviceData will update the "devices" collection
       * 2. deviceCommands will update the "deviceCommands" collection
       * 3. deviceSettings will update the "deviceSettings" collection
       */
      if (collectionKey == "deviceData") {
        await deviceCollection.child(id).set(device.deviceData.toJson());
      } else if (collectionKey == "deviceCommands") {
        await commandsCollection.child(id).set(device.deviceCommands.toJson());
      } else if (collectionKey == "deviceSettings") {
        await settingsCollection.child(id).set(device.deviceSettings.toJson());
      }
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to update device: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to update a device";
    } catch (e) {
      debugPrint("Generic Exception: Failed to update device: ${e.toString()}");
      throw "Failed to update the device: ${e.toString()}";
    }
  }

  /// removeDevices method
  /// This method is responsible for clearing the devices map
  removeDevices() {
    /**
     * Map through the list of devices and remove all subscriptions
     */
    for (String deviceID in deviceListeners.keys) {
      /**
       * Map through listeners and remove each listener individually
       */
      for (StreamSubscription listener in deviceListeners[deviceID]!) {
        listener.cancel();
      }
    }

    /**
     * Once all subscriptions are cancelled, clear both the devices and the listeners maps
     */
    deviceListeners = {};
    devices = {};

    notifyListeners();
  }

  deleteDeviceData(String id) async {
    try {
      await deviceCollection.child(id).remove();
      await settingsCollection.child(id).remove();
      await logsCollection.child(id).remove();
      await commandsCollection.child(id).remove();
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to delete device data: ${e.toString()}");
      throw e.message ?? "Something went wrong while remove device data";
    } catch (e) {
      debugPrint("Generic Exception: Failed to delete device data: ${e.toString()}");
      throw "Failed to delete device data: ${e.toString()}";
    }
  }
}
