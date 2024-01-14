// // home.dart

// import 'package:flutter/material.dart';

// class Home extends StatelessWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//          child: Text(
//            'Welcome to Sahaya',
//            style: TextStyle(color: Colors.grey),  
//          ),
//        ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_config/flutter_config.dart';

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   late GoogleMapController mapController;
//   late LatLng currentLocation;
//   bool locationLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   void _getCurrentLocation() async {
//     var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       currentLocation = LatLng(position.latitude, position.longitude);
//       locationLoaded = true;
//     });
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: locationLoaded ? GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: currentLocation,
//           zoom: 15.0,
//         ),
//         circles: {
//           Circle(
//             circleId: CircleId('current_location'),
//             center: currentLocation,
//             radius: 300, // Radius in meters
//             fillColor: Colors.green.withOpacity(0.5),
//             strokeColor: Colors.green,
//             strokeWidth: 3,
//           ),
//         },
//       ) : Center(child: CircularProgressIndicator()),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Add this import for rootBundle
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController mapController;
  late LatLng currentLocation;
  bool locationLoaded = false;
  CameraPosition currentCameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 0);
  String _mapStyle = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMapStyle();
  }

  void _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/maps/map_style.json');
  }

  void _getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      locationLoaded = true;
      currentCameraPosition = CameraPosition(target: currentLocation, zoom: 15.0);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  void _onCameraMove(CameraPosition position) {
    currentCameraPosition = position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: locationLoaded ? GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: currentCameraPosition,
        onCameraMove: _onCameraMove,
        zoomControlsEnabled: false, // Disable zoom controls
        circles: {
          Circle(
            circleId: CircleId('current_location'),
            center: currentLocation,
            radius: 200, // Radius in meters
            fillColor: Colors.green.withOpacity(0.5),
            strokeColor: Colors.green[800]!,
            strokeWidth: 3,
          ),
        },
        markers: {
          if (currentCameraPosition.zoom < 10) // Adjust zoom level as needed
            Marker(
              markerId: MarkerId('current_location_marker'),
              position: currentLocation,
            ),
        },
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}
