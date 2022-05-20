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

  Profile? profile;
  bool _isLoading = false;
  bool initialized = false;

  /// Stream subscription and the values on change
  StreamSubscription? profileListener;
  StreamSubscription? devicesListener;
  Object? profileData;
  Object? deviceAccessData;

  /// Loader getter and setter
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Methods
  String getUserID() {
    return auth.currentUser!.uid;
  }

  void initialize() {
    if (!initialized) {
      auth = FirebaseAuth.instance;
      users = FirebaseDatabase.instance.ref('users');
      devices = FirebaseDatabase.instance.ref('deviceAccess');
      FirebaseDatabase.instance.setPersistenceEnabled(true);

      initialized = true;
    }
  }

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

  Future<bool?> login(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email.trim(), password: password);

      if (userCredential.user == null) {
        throw Exception("Error occured while trying to login");
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

  Future<void> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String callingCode,
    String phone,
  ) async {
    try {
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception("Error occured while trying to register user");
      }

      final Profile tempProfile = Profile(
        email: email,
        phone: phone,
        code: callingCode,
        name: '$firstName $lastName',
        is24Hours: true,
        temperatureUnit: "C",
        devices: [],
        accessesProvidedToUsers: [],
        fcmToken: await getFCMToken(),
      );

      final Map<String, dynamic> profileData = tempProfile.toJSON();
      profileData.remove('email');

      final String userID = auth.currentUser!.uid;
      await users.child(userID).set(profileData);

      await userCredential.user?.sendEmailVerification();
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Registration Failed: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to register user";
    } catch (e) {
      debugPrint("Generic Exeption: Registration Failed: ${e.toString()}");
      throw "Failed to register the user: ${e.toString()}";
    }
  }

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

  Future<void> attachProfileListener() async {
    try {
      final String userID = auth.currentUser!.uid;

      final DatabaseReference documentRef = users.child(userID).ref;
      final DatabaseReference devicesAccessRef = devices.ref;

      /**
       * Getting initial data from database and transforming that to profile data
       */
      final DataSnapshot document = await documentRef.get();
      final DataSnapshot devicesList = await devicesAccessRef.get();

      if (!document.exists) {
        throw Exception("User profile does not exist");
      }

      profileData = document.value;
      deviceAccessData = devicesList.value;

      transformMapToProfile(profileData, deviceAccessData);

      profileListener = documentRef.onValue.listen((event) {
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
      throw "Generic Exception: Failed to get user profile data";
    }
  }

  Future<void> updateProfile() async {
    try {
      notifyListeners();

      if (profile == null) {
        throw "Failed to get the profile data";
      }

      final Map<String, dynamic> data = profile!.toJSON();
      data.remove('email');

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
      newData['devices'] = newDevices.values.where((element) => element["userID"] == userID).toList();
      newData['access'] = newDevices.values.where((element) => element["accessProvidedBy"] == userID).toList();

      profile = Profile.fromMap(newData);
    } catch (e) {
      throw "Generic Exception: Failed to transform profile data ${e.toString()}";
    }
  }

  Future<void> addDevice(String deviceID, {String? accessProvidedBy, AccessType? accessType}) async {
    try {
      /**
       * Assert that either both are provided or none is provided
       */
      assert((accessProvidedBy == null && accessType == null) || (accessProvidedBy != null && accessType != null));

      /**
       * Generate a unique id using uuid package
       */
      const Uuid uuid = Uuid();
      final String id = uuid.v4();

      devices.child(id).set({
        "deviceID": deviceID,
        /**
         * In case if there's someone who is providing access then set the accessType to the
         * one as being provided... otherwise if there's no one providing access, i.e. user is
         * adding device for himself... then set him as owner
         */
        "accessType": accessProvidedBy != null
            ? accessType != null
                ? accessType.value
                : AccessType.guest.value
            : "owner",
        "accessProvidedBy": accessProvidedBy,
        "userID": getUserID(),
      });
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

      /**
       * Variables to hold the values
       */
      final Map<String, ConnectedDevice> mapOfUsersWithDeviceAccess = {};

      int ownerCount = 0;
      late final String accessID;
      late final ConnectedDevice device;

      for (MapEntry<Object?, Object?> entry in (mapData.value as LinkedHashMap<Object?, Object?>).entries) {
        final String key = entry.key as String;
        final ConnectedDevice value = ConnectedDevice.fromMap((entry.value as LinkedHashMap<Object?, Object?>).cast<String, dynamic>());

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

  Future<void> updateAccessType(String deviceID, AccessType newAccessType, String targetUserID) async {
    try {
      /**
       * Getting the db reference to the device access where the
       * user id is the one to whom the current user has provided access to
       * 
       */
      final DatabaseReference ref = devices.orderByChild("userID").equalTo(targetUserID).ref.orderByChild("deviceID").equalTo(deviceID).ref;

      ref.child("accessType").set(newAccessType.value);
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to change user access type: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to change the user access type";
    } catch (e) {
      debugPrint("Generic Exception: Failed to change user access type: ${e.toString()}");
      throw "Failed to change user access type: ${e.toString()}";
    }
  }

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
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to send password reset emali: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to send the password reset email";
    } catch (e) {
      debugPrint("Generic Exception: Failed to send password reset email: ${e.toString()}");
      throw "Failed to send password reset email: ${e.toString()}";
    }
  }

  AccessType getAccessType(String id) {
    return profile!.devices.firstWhere((element) => element.id == id).accessType;
  }
}
