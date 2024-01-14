// main.dart
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'getPhoneNumber.dart';
import 'home.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // Load env
  await FlutterConfig.loadEnvVariables();
  
  // Check if phone number is set
  final prefs = await SharedPreferences.getInstance();
  var phoneNumber = prefs.getString('phoneNumber');
  
  runApp(MyApp(phoneNumber: phoneNumber));
}

class MyApp extends StatelessWidget {
  final String? phoneNumber;

  const MyApp({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahaya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: phoneNumber == null ? GetPhoneNumber() : Home(),
    );
  }
}
