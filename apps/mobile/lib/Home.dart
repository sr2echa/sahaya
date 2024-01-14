// home.dart

import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
         child: Text(
           'Welcome to Sahaya',
           style: TextStyle(color: Colors.grey),  
         ),
       ),
    );
  }
}