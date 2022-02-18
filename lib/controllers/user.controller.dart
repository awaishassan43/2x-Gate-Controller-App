import 'dart:async';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '/models/profile.model.dart';
import '/util/functions.util.dart';

class UserController extends ChangeNotifier {
  late final FirebaseAuth auth;
  late final DatabaseReference users;
  Profile? profile;
  bool _isLoading = false;
  StreamSubscription? profileListener;

  /// Loader getter and setter
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool?> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Initializing firebase and collections
      await Firebase.initializeApp();
      auth = FirebaseAuth.instance;
      users = FirebaseDatabase.instance.ref('users');

      // Getting logged in user
      final bool? isLoggedIn = await getLoggedInUser();
      return isLoggedIn;
    } on FirebaseException catch (e) {
      throw "Error occured while initializing the app: ${e.message}";
    } catch (e) {
      throw "Failed to initialize the app: ${e.toString()}";
    }
  }

  String getUserID() {
    return auth.currentUser!.uid;
  }

  Future<bool?> getLoggedInUser() async {
    try {
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
      throw "Error occured while getting the user profile: ${e.message}";
    } catch (e) {
      throw "Failed to get the user profile: ${e.toString()}";
    }
  }

  Future<bool?> login(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception("Error occured while trying to login");
      }

      final bool? isLoggedIn = await getLoggedInUser();

      return isLoggedIn;
    } on FirebaseException catch (e) {
      throw "Error occured while logging in the user: ${e.message}";
    } catch (e) {
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
      );

      final Map<String, dynamic> profileData = tempProfile.toJSON();
      profileData.remove('email');

      final String userID = auth.currentUser!.uid;
      await users.child(userID).set(profileData);

      await userCredential.user?.sendEmailVerification();
    } on FirebaseException catch (e) {
      throw "Error occured while registering the user: ${e.message}";
    } catch (e) {
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
    } catch (e) {
      throw "Failed to attach listener to the profile: ${e.toString()}";
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
      throw "Error occured while trying to update the profile: ${e.message}";
    } catch (e) {
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
      throw "Error occured while attaching the device to user: ${e.message}";
    } catch (e) {
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
      throw "Error occured while removing the device: ${e.message}";
    } catch (e) {
      throw "Failed to remove the device: ${e.toString()}";
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
      throw "Error occured while logging out the user: ${e.message}";
    } catch (e) {
      throw "Failed to logout the user: ${e.toString()}";
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      throw "Error occured while sending the email to reset the password: ${e.message}";
    } catch (e) {
      throw "Failed to send the email to reset the password: ${e.toString()}";
    }
  }
}
