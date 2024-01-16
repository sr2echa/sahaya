import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle; 
import 'package:shared_preferences/shared_preferences.dart'; 

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_fonts/google_fonts.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
// import 'package:material_segmented_control/material_segmented_control.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // <--------------------- Initializations --------------------->

  Completer<GoogleMapController> _controllerCompleter = Completer();
  late GoogleMapController mapController;
  late LatLng currentLocation = LatLng(0, 0);
  bool locationLoaded = false;
  CameraPosition currentCameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 0);
  String _mapStyle = '';
  bool isHelping = false;

  List<Map<String, dynamic>> filtersNeedHelp = [
    {"type": "Hospital", "icon": FontAwesomeIcons.truckMedical},
    {"type": "Relief Camp", "icon": FontAwesomeIcons.tent},
    {"type": "Safe Space", "icon": FontAwesomeIcons.home},
    {"type": "Supplies", "icon": FontAwesomeIcons.boxOpen},
  ];
 
    List<Map<String, dynamic>> filtersGiveHelp = [
      {"type": "Volunteer", "icon": FontAwesomeIcons.handsHelping},
      {"type": "Donate", "icon": FontAwesomeIcons.gift},
      {"type": "Shelter", "icon": FontAwesomeIcons.home},
      {"type": "Food", "icon": FontAwesomeIcons.utensils},
    ];
  
  String selectedFilter = '';

 
  // <--------------------- Map Elements --------------------->

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMapStyle();
    _loadModePreference();
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
    _controllerCompleter.complete(controller);
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  void _loadModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isHelping = prefs.getBool('mode') ?? false;
    });
  }


  // Set<Circle> _buildCircles() {
  //   return {
  //     Circle(
  //       circleId: CircleId('current_location'),
  //       center: currentLocation,
  //       radius: 200,
  //       fillColor: Colors.green.withOpacity(0.5),
  //       strokeColor: Colors.green[800]!,
  //       strokeWidth: 3,
  //     ),
  //   };
  // }

  // Set<Marker> _buildMarkers() {
  //   return {
  //     if (currentCameraPosition.zoom < 10) 
  //       Marker(
  //         markerId: MarkerId('current_location_marker'),
  //         position: currentLocation,
  //       ),
  //   };
  // }

  //<--------------------- Misc --------------------->
  // void _toggleMode(bool value) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     isHelping = value;
  //     print(isHelping);
  //     prefs.setBool('mode', isHelping);
  //   });
  // }

  // <--------------------- Actions --------------------->

  dynamic actionButtonClickFn() {
    // Placeholder function to print the details
    print("-------------------------------------------------------------------------------------------------");
    print('Current Location: $currentLocation');
    print('Selected Filter: $selectedFilter');
    print('Selected Mode: ${isHelping ? "Helping" : "Need Help"}');
    
  }
  
  // <--------------------- UI --------------------->

  Widget _buildTopFloatingBar() {
    return Container( 
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      child:Positioned(
        // top: MediaQuery.of(context).padding.top + 10,
        left: MediaQuery.of(context).size.width * 0.075,
        right: MediaQuery.of(context).size.width * 0.075,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 227, 227, 227),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoSlidingSegmentedControl<int>(
                  children: {
                    0: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Need Help',
                        style: GoogleFonts.getFont(
                        'Lexend',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isHelping ? Colors.grey : Colors.redAccent
                        ),
                      ),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Give Help',
                        style: GoogleFonts.getFont(
                        'Lexend',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isHelping ? Colors.blue : Colors.grey
                        ),
                      ),
                    ),
                  },
                  groupValue: isHelping ? 1 : 0,
                  onValueChanged: (int? value) {
                    setState(() {
                      isHelping = value == 1;
                    });
                  },
                  backgroundColor: Color.fromARGB(255, 227, 227, 227),
                  thumbColor: Colors.white,
                  
                  // Add Styles if needed <-->

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildFilterBar() {
    List<Map<String, dynamic>> currentFilters = isHelping ? filtersGiveHelp : filtersNeedHelp;
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(  
        scrollDirection: Axis.horizontal,
        itemCount: currentFilters.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> filter = currentFilters[index];
          bool isSelected = filter['type'] == selectedFilter;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 3),
            child: FilterChip(
              avatar: Icon(filter['icon'], color: isSelected ? Colors.white : Colors.grey),
              label: Text(filter['type'], style: GoogleFonts.getFont(
                'Lexend',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.grey
              )),
              selected: isSelected,
              onSelected: (bool value) {
                setState(() {
                  selectedFilter = value ? filter['type'] : '';
                });
              },
              backgroundColor: Color.fromARGB(255, 227, 227, 227),
              selectedColor: isHelping ? Color.fromARGB(255, 137, 202, 255) : Color.fromARGB(255, 250, 121, 121),
              checkmarkColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.transparent,
                ),
              ),
              shadowColor: Colors.black,
              elevation: 3  ,

              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
  

Widget recenterBtn(Completer<GoogleMapController> controllerCompleter, LatLng currentLocation) {
    return FutureBuilder<GoogleMapController>(
      future: controllerCompleter.future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Positioned(
            right: 20.0,
            bottom: 90.0,
            child: FloatingActionButton(
              mini: false,
              child: Icon(FontAwesomeIcons.streetView, color: Colors.black),
              backgroundColor: Colors.white,
              onPressed: () {
                snapshot.data!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: currentLocation,
                      zoom: 15.0,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget actionBtn(isHelping, currentLocation, selectedFilter) {
    return Positioned(
      right: 20.0,
      bottom: 20.0,
      child: buildFloatingActionButton(
        isHelping: isHelping,
        currentLocation: currentLocation,
        selectedFilter: selectedFilter,
      ),
    );
  }

  Widget buildFloatingActionButton({
    required bool isHelping,
    required LatLng currentLocation,
    required String selectedFilter,
  }) {
    return FloatingActionButton(
      
      child: Icon(
        isHelping ? FontAwesomeIcons.handHoldingHeart : FontAwesomeIcons.handsHelping,
        color: Colors.white,
      ),
      
      backgroundColor: isHelping ? Color.fromARGB(255, 137, 202, 255) : Color.fromARGB(255, 250, 121, 121),
      onPressed: actionButtonClickFn,
    );
  }


  // <--------------------- Build --------------------->
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          locationLoaded ? GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: currentCameraPosition,
            onCameraMove: (position) => currentCameraPosition = position,
            zoomControlsEnabled: false,
            // circles: _buildCircles(),
            // markers: _buildMarkers(),
          ) : Center(child: CircularProgressIndicator()),
          Column(
            children:[
              _buildTopFloatingBar(),
              _buildFilterBar(),
            ]
          ),
          
          recenterBtn(_controllerCompleter, currentLocation),
          actionBtn(isHelping, currentLocation, selectedFilter),
        ],
      ),
    );
  }
}
