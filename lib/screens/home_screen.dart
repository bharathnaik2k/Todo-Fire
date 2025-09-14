import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_firebase/auth/oauth_googlesignin.dart';

class HomeScreen extends StatefulWidget {
  final UserCredential? userCredential;
  const HomeScreen({super.key, this.userCredential});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController titleInput = TextEditingController();
  final TextEditingController description = TextEditingController();
  @override
  void initState() {
    getData();
    super.initState();
  }

  String? displayName;
  String? email;
  String? photoURL;
  String? uid;

  // Map<dynamic, dynamic> allTodo = [];

  List<Map<String, dynamic>> allTodos = [];

  void getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString("displayName");
    // log("${prefs.getString("displayName")}");
    email = prefs.getString("email");
    photoURL = prefs.getString("photoURL");
    uid = prefs.getString("uid");
    setState(() {});
    getUser();
  }

  void loadTodos() {
    FirebaseFirestore.instance.collection("").get().asStream();
  }

  Future<void> getDataTodo() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();

    for (var doc in snapshot.docs) {
      print(doc.id); // document id
      print(doc['name']); // field 'name'
      print(doc['email']); // field 'email'
    }
  }

  Future<void> getUser() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo') // sub-collection
        .get();

    // for (var doc in snapshot.docs) {
    //   allTodo = doc.data();
    //   print("${doc.id} => ${doc.data()}");
    // }

    allTodos = snapshot.docs.map((doc) {
      var data = doc.data();

      return {
        "id": doc.id,
        "title": data['title'],
        "description": data['description'],
        "isDone": data['isDone'],
        // "createdAt": (data['createdAt'] as Timestamp)
        //     .toDate(), // convert Timestamp to DateTime
      };
    }).toList();
    setState(() {});
    log(allTodos.toString());
  }

  Future<void> addTodo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo')
        .add({
      'title': titleInput.text,
      'description': description.text,
      'createdAt': DateTime.now(),
      'isDone': false,
    });
    getUser();
  }

  Future<void> updateTodo(String uid, String todoId, bool done) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo')
        .doc(todoId)
        .update(
      {
        'isDone': done,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 180, 248, 255),
      appBar: appbar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
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
                  CachedNetworkImage(
                    height: 70,
                    width: 70,
                    imageUrl: photoURL.toString(),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        image: DecorationImage(
                          image: imageProvider,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Name : $displayName",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Email : $email",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Mob.   : ${"N/A"}",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                minimumSize: WidgetStatePropertyAll(
                  Size(double.infinity, 30),
                ),
              ),
              onPressed: () {
                OauthGoogleSignIn().signOut(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Logut Account",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.amberAccent,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTodos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(allTodos[index]["title"].toString()),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                title: Text(
                  'Add your todo notes',
                  style: TextStyle(fontSize: 18),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleInput,
                        decoration: InputDecoration(
                          hintText: "Enter title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        maxLines: 10,
                        minLines: 5,
                        controller: description,
                        decoration: InputDecoration(
                          hintText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              const Color.fromARGB(255, 255, 176, 170),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            titleInput.clear();
                            description.clear();
                            Navigator.of(context).pop(); // Dismiss the dialog
                          },
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              const Color.fromARGB(255, 113, 255, 120),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            addTodo();
                            Navigator.of(context).pop(); // Dismiss the dialog
                          },
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
        backgroundColor: const Color.fromARGB(255, 255, 187, 187),
        shape: StadiumBorder(),
        label: Row(
          children: [
            // Text("🔥"),
            Icon(Icons.add),
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
