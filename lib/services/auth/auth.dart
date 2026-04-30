import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/firebase_options.dart';

class Auth {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      await init();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> signup({required String email, required String password}) async {
    try {
      await init();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await init();
    await FirebaseAuth.instance.signOut();
  }

  bool isLoggedIn() {
    if (kIsWeb || _initialized) {
      return FirebaseAuth.instance.currentUser != null;
    }
    return false;
  }
}
