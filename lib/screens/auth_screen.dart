import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_firebase/auth/oauth_googlesignin.dart';
import 'package:todo_firebase/constants/assets_cont.dart';
import 'package:todo_firebase/constants/router/page_navigator.dart';
import 'package:todo_firebase/screens/home_screen.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;

  @override
  void initState() {
    // da(context);
    super.initState();
  }

  Future<void> da(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    String? idToken = prefs.getString("idToken");
    log(accessToken.toString());
    log(idToken.toString());

    if (idToken == null) {
      return;
    }
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
      log("4");

      if (!documentSnapshot.exists) {
        await userDoc.set({
          "uid": user.uid,
          "email": user.email,
          "displayName": user.displayName ?? "",
          "photoURL": user.photoURL ?? "",
          "providerData": "bharathnaik2k",
          "createdAt": FieldValue.serverTimestamp(),
        });
        log("5");
      }
      PageNavigator().pushReplacementNav(context, HomeScreen());
    }
  }

  Future<void> googleSignIn() async {
    isLoading = true;
    setState(() {});
    final userCredential = await OauthGoogleSignIn().oAuthSignIn();
    if (userCredential == null) {
      isLoading = false;
      setState(() {});
      return;
    }
    if (!mounted) return;
    if (userCredential.user != null) {
      log(userCredential.user!.displayName.toString());
      PageNavigator().pushReplacementNav(
        context,
        HomeScreen(userCredential: userCredential),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<AuthScreenController>(context, listen: false);
    log("created");
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 168, 230, 255),
              Color.fromARGB(255, 83, 147, 145)
            ],
          )),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        SplashImages.logo,
                        scale: 4,
                      ),
                      Text(
                        "Your, Todo Fire",
                        style: TextStyle(
                          fontSize: 30,
                          color: const Color.fromARGB(255, 151, 48, 48),
                        ),
                      ),
                      SizedBox(height: 88),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Create account to continue",
                            style: TextStyle(
                              // fontSize: 30,
                              color: const Color.fromARGB(255, 50, 50, 50),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            foregroundColor: WidgetStatePropertyAll(
                                const Color.fromARGB(255, 0, 0, 0)),
                            backgroundColor: WidgetStatePropertyAll(
                                const Color.fromARGB(255, 230, 230, 230)),
                          ),
                          onPressed: () {
                            // PageNavigator().pushNav(context, HomeScreen());
                            googleSignIn();
                          },
                          child:
                              //  CircularProgressIndicator(),
                              Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon(
                              //   MyFlutterApp.google,
                              //   color: const Color.fromARGB(255, 0, 0, 0),
                              //   size: 18,
                              // ),
                              SvgPicture.asset(
                                SvgImages.googleLogo,
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Continue with Google",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            foregroundColor: WidgetStatePropertyAll(
                                const Color.fromARGB(255, 0, 0, 0)),
                            backgroundColor: WidgetStatePropertyAll(
                              const Color.fromARGB(255, 230, 230, 230),
                            ),
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "this feature unavailable right now",
                              fontSize: 12.0,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                SvgImages.appleLogo,
                                width: 20,
                                height: 20,
                              ),
                              // Icon(
                              //   MyFlutterApp.apple,
                              //   color: const Color.fromARGB(255, 0, 0, 0),
                              // ),
                              SizedBox(width: 5),
                              Text(
                                "Continue with Apple",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              const Color.fromARGB(255, 0, 0, 0),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              const Color.fromARGB(255, 230, 230, 230),
                            ),
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "this feature unavailable right now",
                              fontSize: 12.0,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                SvgImages.githubLogo,
                                width: 20,
                                height: 20,
                              ),
                              // Icon(
                              //   MyFlutterApp.github,
                              //   color: const Color.fromARGB(255, 0, 0, 0),
                              // ),
                              SizedBox(width: 5),
                              Text(
                                "Continue with Github",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
