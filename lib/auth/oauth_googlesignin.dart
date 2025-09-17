import 'dart:core';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_firebase/constants/router/page_navigator.dart';
import 'package:todo_firebase/screens/auth_screen.dart';

class OauthGoogleSignIn {
  final String _serverClientId =
      "835386941813-jsdpgolud7oml2emukmnsjngf48mngv6.apps.googleusercontent.com";
  final GoogleSignIn signIn = GoogleSignIn.instance;
// unawaited(signIn
//     .initialize(clientId = clientId, serverClientId = serverClientId)
//     .then((_) {
//   signIn.authenticationEvents
//       .listen(_handleAuthenticationEvent)
//       .onError(_handleAuthenticationError);
//   signIn.attemptLightweightAuthentication();
// }))
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isInitialized = false;

  Future<void> initialized() async {
    try {
      if (!_isInitialized) {
        await _googleSignIn.initialize(
          serverClientId: _serverClientId,
        );
      }
      _isInitialized = !_isInitialized;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserCredential?> oAuthSignIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      initialized();
      final GoogleSignInAccount signIn = await _googleSignIn.authenticate();
      final idToken = signIn.authentication.idToken;
      final authorizationClient = signIn.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(["email", "profile"]);
      final accessToken = authorization?.accessToken;
      if (accessToken == null) {
        final authorization2 = await authorizationClient
            .authorizationForScopes(["email", "profile"]);
        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "erorr", message: "erorr");
        }
        authorization = authorization2;
      }
      log("1");
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      log("2");

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      log("3");

      final User? user = userCredential.user;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection("users").doc(user.uid);
        final documentSnapshot = await userDoc.get();
        await prefs.setString("displayName", user.displayName.toString());
        await prefs.setString("email", user.email.toString());
        await prefs.setString("photoURL", user.photoURL.toString());
        await prefs.setString("uid", user.uid.toString());

        log("4");

        if (!documentSnapshot.exists) {
          await userDoc.set({
            "uid": user.uid,
            "email": user.email,
            "displayName": user.displayName ?? "",
            "photoURL": user.photoURL ?? "",
            "providerData": "google",
            "createdAt": FieldValue.serverTimestamp(),
          });
          log("5");
        }
        log("6");
      }
      log(userCredential.toString());
      return userCredential;
    } catch (e) {
      Fluttertoast.showToast(msg: "Canceled");
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      PageNavigator().pushNav(context, AuthScreen());
    } catch (e) {
      throw e.toString();
    }
  }
}
