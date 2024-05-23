import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Utils/firebase_config.dart';
import 'package:logsan_app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: FireBaseConfig.config);
  runApp(App());
}
