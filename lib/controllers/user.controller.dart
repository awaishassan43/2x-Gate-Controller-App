import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iot/models/profile.model.dart';

class _UserControllerClass {
  late final FirebaseAuth auth;
  late final CollectionReference users;
  static _UserControllerClass? instance;
  Profile? profile;

  static _UserControllerClass getInstance() {
    if (instance == null) {
      final _UserControllerClass newInstance = _UserControllerClass();
      instance = newInstance;

      return newInstance;
    }

    return instance!;
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    auth = FirebaseAuth.instance;
    users = FirebaseFirestore.instance.collection('users');
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

      await getProfile(querySnapshot.docs.first.reference);

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
      });

      await getProfile(reference);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  getProfile(DocumentReference<Object?> reference) async {
    reference.snapshots().listen((snapshot) {
      print("Received snapshot: ${snapshot.data}");
    });
  }
}

final userController = _UserControllerClass.getInstance();
