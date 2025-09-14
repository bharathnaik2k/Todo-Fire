import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_firebase/auth/oauth_googlesignin.dart';

class HomeScreen extends StatefulWidget {
  final UserCredential? userCredential;
  const HomeScreen({super.key, this.userCredential});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 180, 248, 255),
      appBar: appbar(),
      body: Column(
        children: [
          Container(
            // height: 80,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  blurRadius: 1,
                  spreadRadius: 0.1,
                  color: Colors.grey,
                )
              ],
              color: Colors.white,
            ),
            child: Row(
              children: [
                // CachedNetworkImage(
                //   height: 70,
                //   width: 70,
                //   imageUrl:
                //       widget.userCredential!.user!.photoURL.toString() ?? "",
                //   imageBuilder: (context, imageProvider) => Container(
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(8.0),
                //       image: DecorationImage(
                //         image: imageProvider,
                //       ),
                //     ),
                //   ),
                //   placeholder: (context, url) => CircularProgressIndicator(),
                //   errorWidget: (context, url, error) => Icon(Icons.error),
                // ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Text(
                    //   "Name : ${widget.userCredential!.user!.displayName}",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //   ),
                    // ),
                    // Text(
                    //   "Email : ${widget.userCredential!.user!.email}",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //   ),
                    // ),
                    // Text(
                    //   "Mob.   : ${widget.userCredential!.user!.phoneNumber ?? "N/A"}",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //   ),
                    // )
                    IconButton(
                        onPressed: () {
                          OauthGoogleSignIn().signOut(context);
                        },
                        icon: Icon(Icons.logout))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        shape: StadiumBorder(),
        label: Row(
          children: [
            Text("🔥"),
            SizedBox(width: 5),
            Text("Add Fire"),
          ],
        ),
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 210, 210, 210),
      // centerTitle: true,
      title: Text(
        "Welcome, Todo Fire",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
