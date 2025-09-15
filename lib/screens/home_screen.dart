import 'dart:developer';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_firebase/auth/oauth_googlesignin.dart';

class HomeScreen extends StatefulWidget {
  final UserCredential? userCredential;
  const HomeScreen({super.key, this.userCredential});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController titleInput = TextEditingController();
  final TextEditingController description = TextEditingController();
  // @override
  // void initState() {
  //   getData();
  //   super.initState();
  // }

  late AnimationController _controller;

  @override
  void initState() {
    getData();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    Fluttertoast.showToast(msg: "Todo Added");
    titleInput.clear();
    description.clear();
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

  Future<void> deleteTodo(String todoId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo')
        .doc(todoId)
        .delete();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 126, 126, 126),
        appBar: appbar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(6),
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
                  // mainAxisAlignment: ma,
                  children: [
                    CachedNetworkImage(
                      height: 50,
                      width: 50,
                      imageUrl: photoURL.toString(),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          image: DecorationImage(
                            image: imageProvider,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
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
                            fontSize: 10.5,
                          ),
                        ),
                        Text(
                          "Email : $email",
                          style: TextStyle(
                            fontSize: 10.5,
                          ),
                        ),
                        Text(
                          "Mob.   : ${"N/A"}",
                          style: TextStyle(
                            fontSize: 10.5,
                          ),
                        )
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            const Color.fromARGB(255, 255, 225, 223)),
                      ),
                      onPressed: () {
                        OauthGoogleSignIn().signOut(context);
                      },
                      icon: Icon(
                        Icons.logout,
                        color: const Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              // TextButton(
              //   style: ButtonStyle(
              //     backgroundColor: WidgetStatePropertyAll(Colors.red),
              //     minimumSize: WidgetStatePropertyAll(
              //       Size(double.infinity, 30),
              //     ),
              //   ),
              //   onPressed: () {
              //     OauthGoogleSignIn().signOut(context);
              //   },
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Icon(
              //         Icons.logout,
              //         color: Colors.white,
              //       ),
              //       SizedBox(width: 8),
              //       Text(
              //         "Logut Account",
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: Container(
                  // padding: EdgeInsets.all(10),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(8),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       blurRadius: 1,
                  //       spreadRadius: 0.1,
                  //       color: Colors.grey,
                  //     )
                  //   ],
                  // color: const Color.fromARGB(255, 255, 251, 235),
                  // ),
                  child: allTodos.isEmpty
                      ? Center(
                          child: Text(
                            "No Todo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                              bottom: kFloatingActionButtonMargin + 55),
                          itemCount: allTodos.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 1,
                                    spreadRadius: 0.1,
                                    color: Colors.grey,
                                  )
                                ],
                                color: const Color.fromARGB(255, 23, 23, 23),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blueGrey,
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Title : ${allTodos[index]["title"].toString()}"),
                                      Text(
                                          "Description : ${allTodos[index]["description"].toString()}"),
                                    ],
                                  ),
                                  Spacer(),
                                  PopupMenuButton<String>(
                                    surfaceTintColor: Colors.blueAccent,
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Color.fromARGB(255, 0, 0, 255),
                                    ),
                                    color: Color.fromARGB(255, 223, 225, 255),
                                    onSelected: (value) {
                                      //
                                      deleteTodo(
                                          allTodos[index]["id"].toString());
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: '1',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 3),
                                            Text('Update'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: '2',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 3),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(3), // edge thickness
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  // shape: BoxShape.circle,
                  shape: BoxShape.rectangle,
                  gradient: SweepGradient(
                    startAngle: 0.0,
                    endAngle: math.pi * 2,
                    colors: const [
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                      Colors.orange,
                      Colors.blue,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    transform:
                        GradientRotation(_controller.value * 2 * math.pi),
                  ),
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      // traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
                      // anchorPoint: Offset.zero,
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          // contentPadding: EdgeInsets.zero,
                          // actionsPadding: ,
                          // clipBehavior: Clip.hardEdge,
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
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      backgroundColor: WidgetStatePropertyAll(
                                        const Color.fromARGB(
                                            135, 255, 176, 170),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      titleInput.clear();
                                      description.clear();
                                      Navigator.of(context)
                                          .pop(); // Dismiss the dialog
                                    },
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      backgroundColor: WidgetStatePropertyAll(
                                        const Color.fromARGB(
                                            255, 113, 255, 120),
                                      ),
                                    ),
                                    child: Text(
                                      'Save',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      addTodo();
                                      Navigator.of(context)
                                          .pop(); // Dismiss the dialog
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
                  backgroundColor: const Color.fromARGB(153, 100, 100, 100),
                  shape: StadiumBorder(),
                  label: Row(
                    children: [
                      // Text("🔥"),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Add Fire",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }));
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
