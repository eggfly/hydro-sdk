import 'package:hydro_sdk/hc.g.dart';
import 'package:hydro_sdk/runFromBundle.dart';
import 'package:flutter/material.dart';

void main(String path) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RunFromBundle(
    path: path,
    args: [],
    thunks: thunks,
  ));
}
