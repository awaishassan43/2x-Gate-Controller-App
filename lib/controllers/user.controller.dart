import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot/models/profile.model.dart';

class UserController extends ChangeNotifier {
  late final FirebaseAuth auth;
  late final CollectionReference users;
  Profile? profile;
  DocumentSnapshot? profileRef;
  bool _isLoading = false;

  /// Loader getter and setter
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Initializing firebase and collections
      await Firebase.initializeApp();
      auth = FirebaseAuth.instance;
      users = FirebaseFirestore.instance.collection('users');

      // Getting logged in user
      final bool isLoggedIn = await getLoggedInUser();
      return isLoggedIn;
    } on FirebaseException catch (e) {
      throw "Error occured while initializing the app: ${e.message}";
    } catch (e) {
      throw "Failed to initialize the app: ${e.toString()}";
    }
  }

  Future<void> linkDeviceToUser(String deviceID) async {
    try {
      if (profileRef == null) {
        throw Exception("Failed to get user profile");
      }

      final Map<String, dynamic> data = profile!.toJSON();
      (data['devices'] as List<dynamic>).cast<String>().add(deviceID);

      await profileRef!.reference.set(data);
    } on FirebaseException catch (e) {
      throw "Error occured while linking the device to user: ${e.message}";
    } catch (e) {
      throw "Failed to link the device to user: ${e.toString()}";
    }
  }

  Future<void> unlinkDeviceFromUser(String deviceID) async {
    try {
      if (profile == null) {
        throw Exception("Failed to get user profile");
      }

      final Map<String, dynamic> data = profile!.toJSON();
      (data["devices"] as List<dynamic>).cast<String>().remove(deviceID);

      await profileRef!.reference.set(data);
    } on FirebaseException catch (e) {
      throw "Error occured while removing the device from user: ${e.message}";
    } catch (e) {
      throw "Failed to remove the device from user: ${e.toString()}";
    }
  }

  Future<bool> getLoggedInUser() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final DocumentSnapshot<Object?> document = await users.doc(user.email).get();

        if (!document.exists) {
          throw Exception("User profile does not exist");
        }

        transformMapToProfile(document.data());
        await attachProfileListener(document.reference);

        return true;
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      throw "Error occured while getting the user profile: ${e.message}";
    } catch (e) {
      throw "Failed to get the user profile: ${e.toString()}";
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception("Error occured while trying to login");
      }

      final bool isLoggedIn = await getLoggedInUser();

      return isLoggedIn;
    } on FirebaseException catch (e) {
      throw "Error occured while logging in the user: ${e.message}";
    } catch (e) {
      throw "Failed to login the user: ${e.toString()}";
    }
  }

  Future<bool> register(
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
        devices: [],
        email: email,
        phone: phone,
        code: callingCode,
        name: '$firstName $lastName',
        is24Hours: true,
        temperatureUnit: "C",
      );

      final Map<String, dynamic> profileData = tempProfile.toJSON();
      profileData.remove('email');

      final DocumentReference<Object?> document = users.doc(email);
      await document.set(profileData);

      profile = tempProfile;
      await attachProfileListener(document);

      return true;
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

  Future<void> attachProfileListener(DocumentReference<Object?> reference) async {
    try {
      profileRef = await reference.get();
      reference.snapshots().listen((snapshot) {
        transformMapToProfile(snapshot.data());
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile() async {
    try {
      // notifyListeners();

      if (profile == null) {
        throw "Failed to get the profile data";
      }

      final Map<String, dynamic> data = profile!.toJSON();

      await users.doc(profile!.email).set(data);
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
    Map<String, dynamic> newData = data as Map<String, dynamic>;

    newData['email'] = auth.currentUser!.email;
    profile = Profile.fromMap(newData);
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
      profile = null;
      profileRef = null;
    } on FirebaseException catch (e) {
      throw "Error occured while logging out the user: ${e.message}";
    } catch (e) {
      throw "Failed to logout the user: ${e.toString()}";
    }
  }
}
