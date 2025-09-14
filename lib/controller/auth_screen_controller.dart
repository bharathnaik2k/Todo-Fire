import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:todo_firebase/auth/oauth_googlesignin.dart';
import 'package:todo_firebase/constants/router/page_navigator.dart';
import 'package:todo_firebase/screens/home_screen.dart';

class AuthScreenController extends ChangeNotifier {
  // late bool appleClick = false;
  // late bool githubClick = false;
  // void isClicked(int num) {
  //   if (num == 1) {
  //     appleClick = true;
  //   } else if (num == 2) {
  //     githubClick = true;
  //   }
  //   notifyListeners();
  // }
  bool isLoading = false;

  // get mounted => null;

  // bool get mounted => null;
  Future<void> googleSignIn(bool mounted, BuildContext context) async {
    isLoading = true;
    ChangeNotifier();
    final userCredential = await OauthGoogleSignIn().oAuthSignIn();
    if (!mounted) return;
    if (userCredential!.user != null) {
      log(userCredential.user!.displayName.toString());
      PageNavigator().pushNav(context, HomeScreen());
    }
  }
}
