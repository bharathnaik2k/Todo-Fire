import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_firebase/screens/auth_screen.dart';
import 'package:todo_firebase/screens/home_screen.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});
  da(){
    FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // already logged in
          return HomeScreen();
        } else {
          // not logged in
          return AuthScreen();
        }
      },
    );
  }
}
