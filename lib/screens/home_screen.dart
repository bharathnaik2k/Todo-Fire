import 'dart:developer';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
  TextEditingController titleInput = TextEditingController(text: "");
  final TextEditingController description = TextEditingController();

  late AnimationController _controller;

  bool isLoading = false;
  String? displayName;
  String? email;
  String? photoURL;
  String? uid;

  List<Map<String, dynamic>> allTodos = [];

  @override
  void initState() {
    isLoading = true;
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

  void getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString("displayName");
    email = prefs.getString("email");
    photoURL = prefs.getString("photoURL");
    uid = prefs.getString("uid");
    setState(() {});
    getUser();
  }

  Future<void> getUser() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo')
        .orderBy('createdAt', descending: false)
        .get();

    // for (var doc in snapshot.docs) {
    //   allTodo = doc.data();
    //   print("${doc.id} => ${doc.data()}");
    // }

    allTodos = snapshot.docs.map((doc) {
      var data = doc.data();

      DateTime dateTime =
          DateTime.parse((data['createdAt'] as Timestamp).toDate().toString());
      String formatted = DateFormat("hh:mm a - dd/MM/yyyy").format(dateTime);

      return {
        "id": doc.id,
        "title": data['title'],
        "description": data['description'],
        "isDone": data['isDone'],
        "createdAt": formatted,
      };
    }).toList();
    isLoading = false;
    setState(() {});
    log(allTodos.toString());
  }

  // Future<void> addData() async {
  //   final data = {
  //     'name': 'John Doe',
  //     'email': 'john@example.com',
  //     'timestamp': DateTime.now().millisecondsSinceEpoch,
  //   };

  //   await FirebaseFirestore.instance.collection('users').add(data);
  // }

  Stream<QuerySnapshot> getDataInOrder() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> addTodo() async {
    dynamic addedNote = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo')
        .add({
      'title': titleInput.text,
      'description': description.text,
      'createdAt': DateTime.now(),
      'isDone': false,
    });
    log(addedNote.toString());
    Fluttertoast.showToast(msg: "Todo added successful");
    titleInput.clear();
    description.clear();
    getUser();
  }

  Future<void> updateTodo(String todoId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo')
        .doc(todoId)
        .update(
      {
        'title': titleInput.text,
        'description': description.text,
        'createdAt': DateTime.now(),
        'isDone': true,
      },
    );
    Fluttertoast.showToast(msg: "Updated successful");
  }

  Future<void> deleteTodo(String todoId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todo')
        .doc(todoId)
        .delete();
    Fluttertoast.showToast(msg: "Deleted successful");
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              // const Color.fromARGB(255, 241, 158, 255),
              // Colors.red,
              // Colors.orange,
              const Color.fromARGB(255, 106, 106, 106)
            ],
          ),
        ),
        child: Padding(
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
                      color: const Color.fromARGB(255, 80, 80, 80),
                    )
                  ],
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                child: Row(
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
              Divider(
                color: const Color.fromARGB(255, 11, 0, 129),
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              Expanded(
                child: Container(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : allTodos.isEmpty
                          ? Center(
                              child: Text(
                                "No Todo",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 247, 0),
                                  fontSize: 24,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(
                                  bottom: kFloatingActionButtonMargin + 75),
                              itemCount: allTodos.length,
                              itemBuilder: (context, index) {
                                return TweenAnimationBuilder(
                                  tween: Tween<Offset>(
                                    begin: Offset(1, 0),
                                    end: Offset(0, 0),
                                  ),
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeIn,
                                  builder: (context, offset, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                          offset.dx *
                                              MediaQuery.of(context).size.width,
                                          offset.dy),
                                      child: child,
                                    );
                                  },
                                  child: Container(
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
                                      color:
                                          const Color.fromARGB(255, 65, 65, 65),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.primaries[
                                              index % Colors.primaries.length],
                                          child: Text(
                                            "${index + 1}",
                                            style: TextStyle(
                                                color: const Color.fromARGB(
                                                    255, 0, 0, 0)),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                allTodos[index]["title"]
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromARGB(
                                                      255, 242, 255, 0),
                                                  fontSize: 17,
                                                ),
                                              ),
                                              Text(
                                                allTodos[index]["description"]
                                                    .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  allTodos[index]["isDone"]
                                                      ? Text(
                                                          "Edited : ",
                                                          style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                172, 161, 255),
                                                            fontSize: 10,
                                                          ),
                                                        )
                                                      : Text(
                                                          "Created : ",
                                                          style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                109, 255, 98),
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                  Text(
                                                    allTodos[index]["createdAt"]
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        // Spacer(),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                            ),
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            onSelected: (value) {
                                              if (value == "1") {
                                                showDialogButton(context,
                                                    "Update", "Update", 2,
                                                    id: allTodos[index]["id"]
                                                        .toString());
                                                titleInput.text =
                                                    allTodos[index]["title"]
                                                        .toString();
                                                description.text =
                                                    allTodos[index]
                                                            ["description"]
                                                        .toString();

                                                setState(() {});
                                              } else if (value == "2") {
                                                deleteTodo(allTodos[index]["id"]
                                                    .toString());
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: '1',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit_document,
                                                      color: Color.fromARGB(
                                                          255, 71, 62, 255),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Update',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              71,
                                                              62,
                                                              255)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: '2',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: flotingButton(),
    );
  }

  AnimatedBuilder flotingButton() {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
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
                transform: GradientRotation(_controller.value * 2 * math.pi),
              ),
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                showDialogButton(context, "Add", "Save", 1);
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
        });
  }

  Future<dynamic> showDialogButton(
      BuildContext context, String method, String type, dynamic func,
      {String? id}) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          title: Text(
            '$method your todo note',
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLength: 24,
                  controller: titleInput,
                  decoration: InputDecoration(
                    hintText: "Enter title",
                    hintStyle: TextStyle(color: Colors.grey),
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
                    hintStyle: TextStyle(color: Colors.grey),
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
                        const Color.fromARGB(255, 159, 11, 0),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    onPressed: () {
                      titleInput.clear();
                      description.clear();
                      Navigator.of(context).pop();
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
                        const Color.fromARGB(255, 0, 155, 8),
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    onPressed: () {
                      if (titleInput.text.isNotEmpty &&
                          description.text.isNotEmpty) {
                        if (func == 1) {
                          addTodo();
                        } else if (func == 2) {
                          updateTodo(id.toString());
                        }
                        Navigator.of(context).pop();
                      } else {
                        Fluttertoast.showToast(msg: "Fill all fields");
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  AppBar appbar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 0, 161, 172),
      title: Text(
        "Welcome, Todo Fire",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
