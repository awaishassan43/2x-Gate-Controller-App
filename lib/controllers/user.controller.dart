import 'dart:async';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../util/notification.util.dart';
import '/models/profile.model.dart';
import '/util/functions.util.dart';

class UserController extends ChangeNotifier {
  late final FirebaseAuth auth;
  late final DatabaseReference users;
  Profile? profile;
  bool _isLoading = false;
  StreamSubscription? profileListener;
  bool initialized = false;

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

      final DataSnapshot document = await users.child(userID).get();

      if (!document.exists) {
        throw Exception("User profile does not exist");
      }

      transformMapToProfile(document.value);

      profileListener = users.child(userID).onValue.listen((event) {
        transformMapToProfile(event.snapshot.value);
        notifyListeners();
      });
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to attach listeners to user profile: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to get user profile";
    } catch (e) {
      debugPrint("Generic Exception: Failed to attach listeners to user profile: ${e.toString()}");
      throw "Failed to attach listener to user profile: ${e.toString()}";
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
  void transformMapToProfile(Object? data) {
    final newData = (data as LinkedHashMap<Object?, Object?>).cast<String, dynamic>();

    newData['email'] = auth.currentUser!.email!;
    profile = Profile.fromMap(newData);
  }

  Future<void> addDevice(String id) async {
    try {
      final DatabaseReference devicesReference = users.child(auth.currentUser!.uid).child('devices').ref;
      final DataSnapshot data = await devicesReference.get();
      final List<String> devices = data.value != null ? mapToList(data.value as Map) : [];
      devices.add(id);

      await devicesReference.set(listToMap(devices));
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to add device: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to add a device";
    } catch (e) {
      debugPrint("Generic Exception: Failed to add device: ${e.toString()}");
      throw "Failed to attach the device to user: ${e.toString()}";
    }
  }

  Future<void> removeDevice(BuildContext context, String id) async {
    try {
      final DatabaseReference devicesReference = users.child(auth.currentUser!.uid).child('devices').ref;
      final DataSnapshot data = await devicesReference.get();
      final List<String> devices = data.value != null ? List.from((data.value as List<Object?>).cast<String>()) : [];
      devices.remove(id);

      await devicesReference.set(listToMap(devices));
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception: Failed to remove device: ${e.toString()}");
      throw e.message ?? "Something went wrong while trying to remove a device";
    } catch (e) {
      debugPrint("Generic Exception: Failed to remove device: ${e.toString()}");
      throw "Failed to remove the device from user: ${e.toString()}";
    }
  }

  Future<void> logout() async {
    try {
      await auth.signOut();

      /// Cancelling the subscription
      profileListener?.cancel();
      profileListener = null;

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
}
