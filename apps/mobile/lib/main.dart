import 'package:flutter/material.dart';

import 'package:flutter_config/flutter_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'getPhoneNumber.dart';
import 'getPermissions.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  final prefs = await SharedPreferences.getInstance();
  var phoneNumber = prefs.getString('phoneNumber');
  bool permissionsGranted = prefs.getBool('permissionsGranted') ?? false;

  runApp(MyApp(phoneNumber: phoneNumber, permissionsGranted: permissionsGranted));
}

class MyApp extends StatelessWidget {
  final String? phoneNumber;
  final bool permissionsGranted;

  const MyApp({Key? key, required this.phoneNumber, required this.permissionsGranted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahaya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: phoneNumber == null 
          ? GetPhoneNumber() 
          : permissionsGranted 
            ? Home() 
            : GetPermissions(),
    );
  }
}
