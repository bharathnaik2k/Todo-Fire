import 'package:flutter/material.dart';

class PageNavigator {
  void pushNav(BuildContext context, dynamic screenName) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => screenName,
    ));
  }

  void pushReplacementNav(BuildContext context, dynamic screenName) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => screenName,
    ));
  }
}
