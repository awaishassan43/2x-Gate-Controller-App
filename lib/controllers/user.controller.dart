import 'dart:async';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot/util/functions.util.dart';
import 'package:iot/util/themes.util.dart';
import '../enum/access.enum.dart';
import '../enum/route.enum.dart';
import '../util/notification.util.dart';
import '/models/profile.model.dart';
import 'package:uuid/uuid.dart';

class UserController extends ChangeNotifier {
  late final FirebaseAuth auth;
  late final DatabaseReference users;
  late final DatabaseReference devices;

  /// profile property
  /// This property holds the user's profile object based on Profile class
  /// initially and as soon as user logs out, it is set to null
  Profile? profile;

  /// Loading property and getter and setter to be used somewhere in the UI
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// This property controls the initialization of firebase api
  bool initialized = false;

  /// Stream subscription and the respective valuse
  /// 1. profileListener - used to maintain the reference to the user's profile data and is used to cancel the subscription on lougout
  /// 2. devicesListener - used to listen to "deviceAccess" database collection and remove subscription on logout
  /// 3. profileData - contains the data for user's profile
  /// 4. deviceAccessData - contains the list of the devices and the access levels provided to the user
  StreamSubscription? profileListener;
  StreamSubscription? devicesListener;
  Object? profileData;
  Object? deviceAccessData;

  /// getUserID
  /// this method is responsible for getting the user id
  String getUserID() {
    return auth.currentUser!.uid;
  }

  /// initialize
  /// This method is responsible for initializing the auth, devices and the firebase auth instances
  /// as well as setting the offline behavior for the realtime database
  void initialize() {
    if (!initialized) {
      auth = FirebaseAuth.instance;

      /// Reference to the user's collection
      /// this reference is used to retreive and update the user's profile data
      users = FirebaseDatabase.instance.ref('users');

      /// Reference to the deviceAccess collection
      /// this reference is used to retreive the list of the devices that the user has access to
      /// or has provided access to other users
      devices = FirebaseDatabase.instance.ref('deviceAccess');

      initialized = true;
    }
  }

  /// getLoggedInUser
  /// this method is responsible for getting the logged in user from firebase auth
  /// instance and attaching listener to the profile
  /// This method returns a nullable bool value based on whether the user is logged in or not
  /// and whether the profile is verified or not
  /// 1. if user is logged out, then return false
  /// 2. if logged in, then check whether the profile is verified or not
  ///   if the user is verified, then return true,
  ///   otherwise return null
  Future<bool?> getLoggedInUser() async {
    try {
      initialize();

      final User? user = auth.currentUser;

      if (user != null) {
        await attachProfileListener();

        if (user.emailVerified) {
          return true;
        } else {
          return null;
        }
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to get logged in user: " + e.message.toString());
      throw e.message ?? "Something went wrong while trying to login";
    } catch (e) {
      debugPrint("Generic Exeception: Failed to get logged in user: " + e.toString());
      throw "Failed to get logged in user: " + e.toString();
    }
  }

  /// login Method
  /// this method takes in the email and password and logs the user in with firebase auth the credentails
  Future<bool?> login(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email.trim().toLowerCase(), password: password);

      if (userCredential.user == null) {
        throw "Error occured while trying to login";
      }

      /// FCM token is generated every time a user reinstalls the application or clears the cache
      /// So, adding the fcm token in the login as well
      users.child(userCredential.user!.uid).child('fcmToken').set(await getFCMToken());

      final bool? isLoggedIn = await getLoggedInUser();

      return isLoggedIn;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Login Failed: " + e.toString());
      throw e.message ?? "Something went wrong while trying to login";
    } catch (e) {
      debugPrint("FirebaseException: Login Failed: " + e.toString());
      throw "Failed to login the user: ${e.toString()}";
    }
  }

  // register method
  Future<void> register(String email, String password, String firstName, String lastName, String callingCode, String phone) async {
    try {
      /**
       * Register the user
       */
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      if (userCredential.user == null) {
        throw "Error occured while trying to register user";
      }

      /**
       * Create the user profile data
       */
      final Profile tempProfile = Profile(
        email: email.toLowerCase(),
        phone: phone,
        code: callingCode,
        name: '$firstName $lastName',
        is24Hours: true,
        temperatureUnit: "C",
        devices: [],
        accessesProvidedToUsers: [],
        fcmToken: await getFCMToken(),
      );

      /**
       * Convert the profile data to json and remove the email because the email doesn't need to be 
       * saved in the realtime database
       */
      final Map<String, dynamic> profileData = tempProfile.toJSON();

      /**
       * Store the map to the database
       */
      final String userID = auth.currentUser!.uid;
      await users.child(userID).set(profileData);

      /**
       * Send the verification email to the uesr
       */
      await userCredential.user?.sendEmailVerification();
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Registration Failed: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to register user";
    } catch (e) {
      debugPrint("Generic Exeption: Registration Failed: ${e.toString()}");
      throw "Failed to register the user: ${e.toString()}";
    }
  }

  /// updatePassword
  /// this method is responsible for authenticating the user, and updating the password in case if no
  /// error is caught
  Future<void> updatePassword(String oldPass, String newPass) async {
    try {
      if (auth.currentUser == null) {
        throw "Failed to get user profile";
      }

      final AuthCredential credential = EmailAuthProvider.credential(email: auth.currentUser!.email!, password: oldPass);
      await auth.currentUser!.reauthenticateWithCredential(credential);

      await auth.currentUser!.updatePassword(newPass);
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Exception: Failed to update password: ${e.toString()}");
      throw "Error occured while trying to update the password: ${e.message}";
    } catch (e) {
      throw "Failed to update the password: ${e.toString()}";
    }
  }

  /// this method is responsible for attaching the listener to the database collections
  Future<void> attachProfileListener() async {
    try {
      /**
       * Get the user id
       */
      final String userID = auth.currentUser!.uid;

      /**
       * Get the reference to the user's profile
       */
      final DatabaseReference documentRef = users.child(userID).ref;
      final DatabaseReference devicesAccessRef = devices.ref;

      /**
       * Getting initial data from database so that it can be transformed to the Profile object
       * for the rest of the app to be used
       */
      final DataSnapshot document = await documentRef.get();
      if (!document.exists) {
        throw ("User profile does not exist");
      }

      /**
       * Get the list of all "deviceAccess" documents, so that it can be filtered based on the 
       * devices that user has access to, and the devices that user has provided access to others
       */
      final DataSnapshot devicesList = await devicesAccessRef.get();

      /**
       * Transforming the retreived data to the profile object
       */
      profileData = document.value;
      deviceAccessData = devicesList.value;

      transformMapToProfile(profileData, deviceAccessData);

      profileListener = documentRef.onValue.listen((event) {
        if (event.snapshot.value == null) {
          return;
        }

        profileData = event.snapshot.value;

        transformMapToProfile(profileData, deviceAccessData);
        notifyListeners();
      });

      devicesListener = devicesAccessRef.onValue.listen((event) {
        deviceAccessData = event.snapshot.value;

        transformMapToProfile(profileData, deviceAccessData);
        notifyListeners();
      });
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to attach listeners to user profile: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to get user profile";
    } catch (e) {
      debugPrint("Generic Exception: Failed to attach listeners to user profile: ${e.toString()}");
      throw "Failed to get user profile data: ${e.toString()}";
    }
  }

  /// This method is responsible for updating the user's profile data
  Future<void> updateProfile() async {
    try {
      notifyListeners();

      if (profile == null) {
        throw "Failed to get the profile data";
      }

      /**
       * Convert the profile to json object and remove email
       * email doesn't need to be saved to the database
       */
      final Map<String, dynamic> data = profile!.toJSON();
      data.remove("devices");
      data.remove("accessesProvidedToUsers");

      await users.child(auth.currentUser!.uid).set(data);
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to update profile: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to update profile";
    } catch (e) {
      debugPrint("Generic Exception: Failed to update profile: ${e.toString()}");
      throw "Failed to update the profile: ${e.toString()}";
    }
  }

  /// Note: The profile data being stored in the firebase does not include email
  /// So manually have to add the email of the signed in user to the profile data map
  /// the return true shows the new value has been applied because it was different from original value
  /// false means... the value didn't update.. .cause it was already updated
  void transformMapToProfile(Object? data, Object? devicesList) {
    try {
      final Map<String, dynamic> newData = (data as LinkedHashMap<Object?, Object?>).cast<String, dynamic>();
      final Map<String, dynamic> newDevices = devicesList == null ? {} : (devicesList as LinkedHashMap<Object?, Object?>).cast<String, dynamic>();

      newData['email'] = auth.currentUser!.email!;

      /**
       * Filter the devices of the current user and assign the list to the newData map
       */
      final String userID = getUserID();
      newData['devices'] =
          newDevices.entries.where((entry) => entry.value["userID"] == userID).map((entry) => {...entry.value, "id": entry.key}).toList();

      newData['access'] = newDevices.entries
          .where((element) => element.value["accessProvidedBy"] == userID)
          .map((entry) => {...entry.value, "id": entry.key})
          .toList();

      profile = Profile.fromMap(newData);
    } catch (e) {
      throw "Failed to transform profile data: ${e.toString()}";
    }
  }

  /// This method helps the user revoke access to the devices that the current user has provided to others
  Future<void> revokeAccess(String accessID) async {
    try {
      await devices.child(accessID).remove();
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to revoke access: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to revoke access";
    } catch (e) {
      debugPrint("Generic Exeption: Failed to revoke access: ${e.toString()}");
      throw "Failed to to revoke access: ${e.toString()}";
    }
  }

  /// addDevice
  /// this method is responsible for adding a deviceAccess record to the database
  /// params (and what they are needed for):
  /// 1. deviceID - the id of the device to be added
  /// 2. forSelf - a boolean value, true means that the user is adding the device for himself
  ///       if false, then it means user intends to share the device with others... in the case of which a sharing key
  ///       is generated as well, and the userID for the device is set as null, as the device has no current user
  /// 3. accessType - an enum value, refering to the type of access that the user is providing
  /// 4. nickName - a string value to help the user identify the accesses he has provided to others
  /// 5. email - a string that can be used to identify the user if the device is to attached directly, i.e. without sharing a link
  Future<String?> addDevice(String deviceID,
      {bool forSelf = false, AccessType accessType = AccessType.owner, String? nickName, String? email}) async {
    try {
      final String userID = getUserID();
      final String currentEmail = getUserEmail();

      if (forSelf || (email != null && email == currentEmail)) {
        final List<ConnectedDevice> alreadyHasADeviceAdded =
            profile!.devices.where((element) => element.deviceID == deviceID && userID == userID).toList();

        if (alreadyHasADeviceAdded.isNotEmpty) {
          throw "User already has the same device added";
        }
      }

      /**
       * Generate a unique id using uuid package
       */
      const Uuid uuid = Uuid();
      final String id = uuid.v4();
      String? key;
      String? targetUserID;

      /**
       * If not creating a deviceAccess document for self, then create a sharing key as well
       */
      if (!forSelf && email == null) {
        key = uuid.v4();
      }

      /**
       * Get user id if email is provided
       */
      if (email != null) {
        final DataSnapshot targetUserData = await users.orderByChild('email').equalTo(email.toLowerCase()).get();
        if (targetUserData.value == null) {
          throw "No registered account was found for the email: " + email;
        }

        final LinkedHashMap<Object?, Object?> targetUser = targetUserData.value! as LinkedHashMap;
        targetUserID = targetUser.keys.first as String;

        // Verify if the user doesn't already have the same device attached
        for (ConnectedDevice connectedDevice in profile!.accessesProvidedToUsers) {
          if (connectedDevice.userID == targetUserID && connectedDevice.deviceID == deviceID) {
            throw "User already has access to the device";
          }
        }
      }

      devices.child(id).set({
        "deviceID": deviceID,
        "accessType": accessType.value,
        "accessProvidedBy": forSelf ? null : userID,
        "key": key,
        "userID": forSelf ? userID : targetUserID,
        "nickName": nickName,
      });

      return key;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to add device: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to add a device";
    } catch (e) {
      debugPrint("Generic Exception: Failed to add device: ${e.toString()}");
      throw "Failed to attach the device to user: ${e.toString()}";
    }
  }

  Future<void> removeDevice(BuildContext context, String deviceID) async {
    try {
      /**
       * Getting the map of users with access to device
       */
      final String userID = getUserID();
      final DataSnapshot mapData = await devices.orderByChild("deviceID").equalTo(deviceID).get();

      if (mapData.value == null) {
        throw "No such device data found";
      }

      /**
       * Variables to hold the values
       */
      final Map<String, ConnectedDevice> mapOfUsersWithDeviceAccess = {};

      int ownerCount = 0;
      late final String accessID;
      late final ConnectedDevice device;

      /**
       * Check if the device has multiple users, then show a dialog to help the user make choice between
       * deleting the device for himself only or for all users, including the ones he shared access with
       */
      for (MapEntry<Object?, Object?> entry in (mapData.value as LinkedHashMap<Object?, Object?>).entries) {
        final String key = entry.key as String;
        final Map<String, dynamic> mappedDevice = (entry.value as LinkedHashMap<Object?, Object?>).cast<String, dynamic>();
        mappedDevice['id'] = entry.key;

        final ConnectedDevice value = ConnectedDevice.fromMap(mappedDevice);

        mapOfUsersWithDeviceAccess[key] = value;

        // Increment the number of owners
        if (value.accessType == AccessType.owner) {
          ownerCount++;
        }

        // Get the data for the current user
        if (value.userID == userID) {
          accessID = key;
          device = value;
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            title: Text(
              "Delete device",
              style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 18),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                /**
                   * Incase if the user is not an admin, simply remove their device access
                   */
                if (device.accessType != AccessType.owner) ...[
                  Text(
                    "Since, you are a \"${device.accessType.value}\" user of the device, deleting it will only revoke your access, and won't remove the device for other users",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontSize: 13,
                          color: textColor,
                        ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          try {
                            await devices.child(accessID).remove();
                            postDelete(context);
                          } catch (e) {
                            rethrow;
                          }
                        },
                        child: const Text("I understand! Remove the device"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                ],

                /**
                   * In case if the user is admin... and there's only one admin
                   */
                if (device.accessType == AccessType.owner) ...[
                  Text(
                    ownerCount > 1
                        ? "Since, there are multiple users with \"${device.accessType.value}\" level access. You can either delete the device for yourself or delete for all other users."
                        : "Please note deleting the device will remove the device for all other non-owner users",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontSize: 13,
                          color: textColor,
                        ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (ownerCount > 1)
                        TextButton(
                          onPressed: () async {
                            try {
                              await devices.child(accessID).remove();
                              postDelete(context);
                            } catch (e) {
                              rethrow;
                            }
                          },
                          child: const Text("Delete only for me"),
                        ),
                      TextButton(
                        onPressed: () async {
                          try {
                            for (String id in mapOfUsersWithDeviceAccess.keys) {
                              await devices.child(id).remove();
                            }
                            postDelete(context);
                          } catch (e) {
                            rethrow;
                          }
                        },
                        child: const Text(
                          "Delete for all",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to remove device: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to remove a device";
    } catch (e) {
      debugPrint("Generic Exception: Failed to remove device: ${e.toString()}");
      throw "Failed to remove the device from user: ${e.toString()}";
    }
  }

  void postDelete(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName(Screen.dashboard));
    showMessage(context, "Device removed successfully!");
  }

  Future<void> addRemoteDevice(String key) async {
    try {
      final String userID = getUserID();

      /**
       * Getting the db reference to the device access where the
       * user id is the one to whom the current user has provided access to
       */
      final DataSnapshot item = await devices.orderByChild("key").equalTo(key).get();

      if (item.value == null) {
        throw "Failed to find data - It seems like access has already been revoked";
      }

      final Map<String, dynamic> data = (item.value as LinkedHashMap<Object?, Object?>).cast<String, dynamic>();

      final String accessKey = data.keys.first;
      final Map<String, dynamic> mappedData = (data.values.first as LinkedHashMap<Object?, Object?>).cast<String, dynamic>();

      /**
       * Check if the mappedData already has a userID assigned to it... if it means, a user is already assigned
       * i.e. if the userid is not null, which means user is assigned to it... then check if it is the same user
       */
      if (mappedData['userID'] != null) {
        if (mappedData['userID'] == userID) {
          throw "User already has access to this device";
        } else {
          throw "A user has already been assigned to the device - Please create a new QR code to share with the user";
        }
      }

      /**
       * Check if the user itself is the one providing the QR code
       */
      if (mappedData['accessProvidedBy'] == userID) {
        throw "Cannot add yourself as another user for the device";
      }

      /**
       * Checking if the user alredy has access to the device through a different access id
       */
      final Iterable<ConnectedDevice> devicesList =
          profile!.accessesProvidedToUsers.where((element) => element.deviceID == mappedData['deviceID'] && element.userID == mappedData['userID']);
      if (devicesList.isNotEmpty) {
        throw "User already has access to the device";
      }

      /**
       * Getting the user id and updating the map to assign the user's id
       * and making the key null, so that the sharing status can be regarded
       * as active - please note non-null value means that the shared access
       * has not yet been accepted... null means that the shared access has been 
       * accepted.. so the key is set to null
       */
      mappedData['userID'] = userID;
      mappedData['key'] = null;

      devices.child(accessKey).set(mappedData);
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to update device access: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to update device access";
    } catch (e) {
      debugPrint("Generic Exception: Failed to update device access: ${e.toString()}");
      throw "Failed to update device access: ${e.toString()}";
    }
  }

  /// this method updates the device access he's provided the other user, like accessType or nickName
  Future<void> updateDeviceAccess(ConnectedDevice updatedAccess) async {
    try {
      final Map<String, dynamic> mappedData = updatedAccess.toJSON();
      devices.child(updatedAccess.id).set(mappedData);
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to change user access type: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to change the user access type";
    } catch (e) {
      debugPrint("Generic Exception: Failed to change user access type: ${e.toString()}");
      throw "Failed to change user access type: ${e.toString()}";
    }
  }

  /// This method logs the user out as well as removes all the listeners associated
  Future<void> logout() async {
    try {
      await auth.signOut();

      /// Cancelling the subscription
      profileListener?.cancel();
      devicesListener?.cancel();
      profileListener = null;
      devicesListener = null;

      /// Setting profile to null
      profile = null;

      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to logout: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to logout";
    } catch (e) {
      debugPrint("Generic Exception: Failed to logout: ${e.toString()}");
      throw "Failed to logout: ${e.toString()}";
    }
  }

  String getUserEmail() {
    return profile!.email;
  }

  Future<void> forgotPassword(String email) async {
    try {
      /**
       * Send the password reset email to the user... the password reset is handled by google itself
       */
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to send password reset emali: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to send the password reset email";
    } catch (e) {
      debugPrint("Generic Exception: Failed to send password reset email: ${e.toString()}");
      throw "Failed to send password reset email: ${e.toString()}";
    }
  }

  /// getAccessType
  /// This method is responsible for the getting the accessType of a particular device
  /// that belongs to the current user....
  AccessType getAccessType(String deviceID) {
    final String userID = getUserID();
    return profile!.devices.firstWhere((element) => element.deviceID == deviceID && element.userID != null && element.userID == userID).accessType;
  }
}
