import 'package:flutter/material.dart';

import 'package:flutter_config/flutter_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'getPhoneNumber.dart';
import 'getPermissions.dart';
import 'Home.dart';
import 'Weather.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;

//   CustomBottomNavigationBar({
//     Key? key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       backgroundColor: Colors.white, // Custom background color
//       selectedItemColor: Colors.blue, // Custom selected item color
//       unselectedItemColor: Colors.grey, // Custom unselected item color
//       selectedFontSize: 14,
//       unselectedFontSize: 14,
//       currentIndex: selectedIndex,
//       onTap: onItemTapped,
//       items: [
//         BottomNavigationBarItem(
//           icon: Icon(FontAwesomeIcons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(FontAwesomeIcons.cloudSunRain),
//           label: 'Weather',
//         ),
//         // Add more items as needed
//       ],
//     );
//   }
// }

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTapped,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 30,
      backgroundColor: Colors.white,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        // NavigationDestination(
        //   icon: Transform.scale(
        //     scale: 0.8, // Scale down the icon size
        //     child: Icon(Icons.house),
        //   ),
        //   selectedIcon: Transform.scale(
        //     scale: 0.8, // Scale down the selected icon size
        //     child: Icon(Icons.home_filled),
        //   ),
        //   label: 'Home',
        // ),
        NavigationDestination(
          icon: Icon(Icons.cloud_outlined),
          selectedIcon: Icon(Icons.cloud),
          label: 'Weather',
        )
      ],
    );
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  final prefs = await SharedPreferences.getInstance();
  var phoneNumber = prefs.getString('phoneNumber');
  bool permissionsGranted = prefs.getBool('permissionsGranted') ?? false;

  runApp(MyApp(phoneNumber: phoneNumber, permissionsGranted: permissionsGranted));
}

// class MyApp extends StatelessWidget {
//   final String? phoneNumber;
//   final bool permissionsGranted;

//   const MyApp({Key? key, required this.phoneNumber, required this.permissionsGranted}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sahaya',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: phoneNumber == null 
//           ? GetPhoneNumber() 
//           : permissionsGranted 
//             ? Home() 
//             : GetPermissions(),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  final String? phoneNumber;
  final bool permissionsGranted;

  const MyApp({
    Key? key,
    required this.phoneNumber,
    required this.permissionsGranted,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahaya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            // This is where the main content of the page goes
            widget.phoneNumber == null
                ? GetPhoneNumber()
                : !widget.permissionsGranted
                    ? GetPermissions()
                    : _getScreenWidget(_selectedIndex),

            // Positioned bottom navigation bar
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: widget.phoneNumber != null && widget.permissionsGranted
                  ? CustomNavigationBar(
                      selectedIndex: _selectedIndex,
                      onItemTapped: _onItemTapped,
                    )
                  : SizedBox.shrink(), // Empty container when nav bar should not be shown
            ),
          ],
        ),
      ),
    );
  }

  Widget _getScreenWidget(int index) {
    Widget content;
    switch (index) {
      case 0:
        content = Home();
        break;
      case 1:
        content = Weather();
        break;
      // Add more cases : additional screens <----->
      default:
        content = Home(); // Default case
    }

    return Padding(
      padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + 20), // Adjust padding based on the nav bar height
      child: content,
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}


