import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class GetPermissions extends StatefulWidget {
  @override
  _GetPermissionsState createState() => _GetPermissionsState();
}

class _GetPermissionsState extends State<GetPermissions> {
  bool locationPermissionGranted = false;
  bool smsPermissionGranted = false;

  void _updatePermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (locationPermissionGranted && smsPermissionGranted) {
      await prefs.setBool('permissionsGranted', true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background/main.png"),
          fit: BoxFit.cover,
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body:Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child:Text(
                  'We need your permission to continue',
                  style: GoogleFonts.getFont(
                    'Lexend',
                    fontSize: 22, 
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ), 
                ),
              ),
              SizedBox(height: 20),
              PermissionRequestTile(
                permission: Permission.location,
                title: 'Location Permission',
                description:
                    'To get the current location so people can request and recieve help at that particular location.',
                isGranted: locationPermissionGranted,
                onGranted: () => setState(() {
                  locationPermissionGranted = true;
                }),
              ),
              SizedBox(height: 10),
              PermissionRequestTile(
                permission: Permission.sms,
                title: 'SMS Permission',
                description:
                    'We use SMS as an API to communicate with our servers in case of no internet, ensuring the app remains functional.',
                isGranted: smsPermissionGranted,
                onGranted: () => setState(() {
                  smsPermissionGranted = true;
                }),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  // onPressed: locationPermissionGranted && smsPermissionGranted
                  //     ? () {
                  //         Navigator.of(context).pushReplacement(
                  //           MaterialPageRoute(builder: (context) => Home()),
                  //         );
                  //       }
                  //     : null,
                  onPressed: locationPermissionGranted && smsPermissionGranted
                    ? _updatePermissionStatus
                    : null,
                  child: Text(
                    'Submit',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      fontSize: 18, 
                      color: Colors.white
                    ), 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionRequestTile extends StatelessWidget {
  final Permission permission;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onGranted;

  const PermissionRequestTile({
    Key? key,
    required this.permission,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onGranted,
  }) : super(key: key);

  void _requestPermission(BuildContext context) async {
    var status = await permission.request();
    if (status.isGranted) {
      onGranted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Permission Denied'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isGranted ? Colors.green[100] : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: isGranted
            ? Icon(Icons.check, color: Colors.green)
            : IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () => _requestPermission(context),
              ),
      ),
    );
  }
}
