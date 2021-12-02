import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iot/models/profile.model.dart';

class UserController extends ChangeNotifier {
  late final FirebaseAuth auth;
  late final CollectionReference users;
  Profile? profile;
  DocumentSnapshot? profileRef;

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> linkDeviceToUser(String deviceID) async {
    try {
      if (profileRef == null) {
        throw Exception("Failed to get user profile");
      }

      final Map<String, dynamic> data = profileRef!.data()! as Map<String, dynamic>;
      (data['devices'] as List<dynamic>).cast<String>().add(deviceID);

      await profileRef!.reference.set(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlinkDeviceFromUser(String deviceID) async {
    try {
      if (profile == null) {
        throw Exception("Failed to get user profile");
      }

      final Map<String, dynamic> data = profileRef!.data()! as Map<String, dynamic>;
      (data['devices'] as List<String>).remove(deviceID);

      await profileRef!.reference.set(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getLoggedInUser() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final QuerySnapshot<Object?> querySnapshot = await users.where('userID', isEqualTo: user.uid).limit(1).get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception("User profile does not exist");
        }

        final QueryDocumentSnapshot<Object?> document = querySnapshot.docs.first;

        if (!document.exists || document.data() == null) {
          throw Exception("User profile does not exist");
        }

        final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        data['email'] = auth.currentUser!.email;
        profile = Profile.fromMap(data);

        await attachProfileListener(querySnapshot.docs.first.reference);
        return true;
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception("Error occured while trying to login");
      }

      final User user = userCredential.user!;
      final QuerySnapshot<Object?> querySnapshot = await users.where('userID', isEqualTo: user.uid).limit(1).get();

      if (querySnapshot.docs.isEmpty || !querySnapshot.docs.first.exists) {
        throw Exception("User profile does not exist");
      }

      await attachProfileListener(querySnapshot.docs.first.reference);

      return true;
    } catch (e) {
      rethrow;
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

      final User user = userCredential.user!;

      final DocumentReference<Object?> reference = await users.add({
        "firstName": firstName,
        "lastName": lastName,
        "code": callingCode,
        "phone": phone,
        "userID": user.uid,
        "devices": [],
      });

      await attachProfileListener(reference);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> attachProfileListener(DocumentReference<Object?> reference) async {
    profileRef = await reference.get();
    reference.snapshots().listen((snapshot) {
      Map<String, dynamic> profileData = snapshot.data() as Map<String, dynamic>;
      profileData['email'] = auth.currentUser!.email;
      profile = Profile.fromMap(profileData);
      notifyListeners();
    });
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
      profile = null;
      profileRef = null;
    } catch (e) {
      rethrow;
    }
  }
}
