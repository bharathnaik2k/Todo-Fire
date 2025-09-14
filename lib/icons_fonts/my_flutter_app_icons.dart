library;

import 'package:flutter/widgets.dart';

class MyFlutterApp {
  MyFlutterApp._();

  static const _kFontFam = 'myflutterapp';
  static const String? _kFontPkg = null;

  static const IconData apple =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData github =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData google =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData settings =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData trash =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
