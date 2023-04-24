// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  bool _emailVerified = false;

  bool get emailVerified => _emailVerified;

  bool _profileSet = false;

  bool get profileSet => _profileSet;

  String _userName = "";

  String get userName => _userName;

  Future<void> checkprofile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('UserProfile')
        .doc(user.uid)
        .get();

    if (docSnapshot.exists) {
      _profileSet = true;
      _userName = docSnapshot.data()!['firstName'] as String;
    } else {
      _profileSet = false;
    }
    notifyListeners(); // Notify listeners after the value of _profileSet is updated
  }

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await checkprofile();

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _emailVerified = user.emailVerified;
        checkprofile(); // Call checkprofile() whenever the authentication state changes
      } else {
        _loggedIn = false;
        _emailVerified = false;
      }
      notifyListeners();
    });
  }

  Future<void> refreshLoggedInUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await currentUser.reload();
    await checkprofile();
  }
}
