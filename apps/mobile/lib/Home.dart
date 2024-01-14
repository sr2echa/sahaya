// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   late GoogleMapController mapController;
//   late LatLng currentLocation;
//   bool locationLoaded = false;
//   CameraPosition currentCameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 0);
//   String _mapStyle = '';

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _loadMapStyle();
//   }

//   void _loadMapStyle() async {
//     _mapStyle = await rootBundle.loadString('assets/maps/map_style.json');
//   }

//   void _getCurrentLocation() async {
//     var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       currentLocation = LatLng(position.latitude, position.longitude);
//       locationLoaded = true;
//       currentCameraPosition = CameraPosition(target: currentLocation, zoom: 15.0);
//     });
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     mapController.setMapStyle(_mapStyle);
//   }

//   void _onCameraMove(CameraPosition position) {
//     currentCameraPosition = position;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: locationLoaded ? GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: currentCameraPosition,
//         onCameraMove: _onCameraMove,
//         zoomControlsEnabled: false, // Disable zoom controls
//         circles: {
//           Circle(
//             circleId: CircleId('current_location'),
//             center: currentLocation,
//             radius: 200, // Radius in meters
//             fillColor: Colors.green.withOpacity(0.5),
//             strokeColor: Colors.green[800]!,
//             strokeWidth: 3,
//           ),
//         },
//         markers: {
//           if (currentCameraPosition.zoom < 10) // Adjust zoom level as needed
//             Marker(
//               markerId: MarkerId('current_location_marker'),
//               position: currentLocation,
//             ),
//         },
//       ) : Center(child: CircularProgressIndicator()),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome
import 'package:flutter/services.dart' show rootBundle; // Add this import for rootBundle


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController mapController;
  late LatLng currentLocation;
  bool locationLoaded = false;
  CameraPosition currentCameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 0);
  String _mapStyle = ''; // Custom map style JSON

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
        circles: _buildCircles(),
        markers: _buildMarkers(),
      ) : Center(child: CircularProgressIndicator()),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Set<Circle> _buildCircles() {
    return {
      Circle(
        circleId: CircleId('current_location'),
        center: currentLocation,
        radius: 200, // Radius in meters
        fillColor: Colors.green.withOpacity(0.5),
        strokeColor: Colors.green[800]!,
        strokeWidth: 3,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    return {
      if (currentCameraPosition.zoom < 10) // Adjust zoom level as needed
        Marker(
          markerId: MarkerId('current_location_marker'),
          position: currentLocation,
        ),
    };
  }

  Widget _buildFloatingActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 0, left: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _customFloatingActionButton(
                title: "Give Help",
                icon: FontAwesomeIcons.handsHelping,
                onPressed: () {
                  // Action for Give Help
                },
                backgroundColor: const Color.fromARGB(255, 167, 215, 255), // Customize this button individually
                // Add other custom styles if needed
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _customFloatingActionButton(
                title: "Need Help",
                icon: FontAwesomeIcons.handHoldingHeart,
                onPressed: () {
                  // Action for Need Help
                },
                backgroundColor: const Color.fromARGB(255, 255, 148, 167), // Customize this button individually
                // Add other custom styles if needed
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customFloatingActionButton({
    required String title, 
    required IconData icon, 
    required VoidCallback onPressed,
    Color backgroundColor = Colors.grey, // Default color, can be overridden
    // Add other styling parameters as needed
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      backgroundColor: backgroundColor,
      // Apply other custom styles here
    );
  }
}
