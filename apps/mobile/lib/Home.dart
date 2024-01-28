import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle; 
import 'package:shared_preferences/shared_preferences.dart'; 

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_fonts/google_fonts.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'package:url_launcher/url_launcher.dart';
// import 'package:material_segmented_control/material_segmented_control.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controllerCompleter = Completer();
  late GoogleMapController mapController;
  late LatLng currentLocation = LatLng(0, 0);
  bool locationLoaded = false;
  CameraPosition currentCameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 0);
  String _mapStyle = '';
  bool isHelping = false;

  late List<Marker> _hospitals = [];
  late List<Marker> _reliefCamps = [];
  late List<Marker> _supplies = [];
  late List<Marker> _shelters = [];


  late List<Marker> _volunteers = [];
  late List<Marker> _food = [];

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMapStyle();
    _loadModePreference();
    _loadJsonData();
  }

  void _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/maps/map_style.json');
  }

  Future<void> _loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/backend.schema.json');
    final jsonResponse = json.decode(jsonString);
    _processJsonData(jsonResponse);
  }

  void _processJsonData(Map<String, dynamic> data) async{
    
    List<Marker> hospitals = [];
    List<Marker> reliefCamps = [];
    List<Marker> supplies = [];
    List<Marker> shelters = [];

    List<Marker> volunteers = [];
    List<Marker> food = [];

    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(28, 28)),
      'assets/maps/markers/hospital.png',
    );

    for (var item in data['need']) {
      LatLng location = LatLng(item['location']['lat'], item['location']['lng']);
      Marker marker = Marker(
        markerId: MarkerId(location.toString()),
        anchor: Offset(0.5 , 0.5),
        position: location,
        icon: icon,

        onTap: () {
          _showLocationDetails(context, item);
        }
      );

      switch (item['type']) {
        case 'hospital':
          hospitals.add(marker);
          break;
        case 'reliefCamp':
          reliefCamps.add(marker);
          break;
        case 'supplies':
          supplies.add(marker);
          break;
        case 'safeSpace':
          shelters.add(marker);
          break;
      }
    }


    for (var item in data['give']) {
      LatLng location = LatLng(item['location']['lat'], item['location']['lng']);
      Marker marker = Marker(
        markerId: MarkerId(item['type'] +  location.toString(),),
        position: location, 
        anchor: Offset(0.5 , 0.5),
        icon: icon,

        onTap: () {
          _showLocationDetails(context, item);
          }
      );

    switch (item['type']) {
      case 'volunteer':
        volunteers.add(marker);
        break;
      case 'food':
        food.add(marker);
        break;
    }
  }

    setState(() {
      _hospitals = hospitals;
      _reliefCamps = reliefCamps;
      _supplies = supplies;
      _shelters = shelters;
      _volunteers = volunteers;
      _food = food;
    });
  }

  
  void _showLocationDetails(BuildContext context, Map<String, dynamic> locationDetails) async {
    final double startLatitude = currentLocation.latitude;
    final double startLongitude = currentLocation.longitude;
    final double endLatitude = locationDetails['location']['lat'];
    final double endLongitude = locationDetails['location']['lng'];

    double distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
    String distanceDisplay = distanceInMeters < 1000
        ? '${distanceInMeters.toStringAsFixed(0)}m'
        : '${(distanceInMeters / 1000).toStringAsFixed(1)}km';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationDetails['type'].toString().toUpperCase(),
                  style: GoogleFonts.getFont(
                    "Lexend",
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Divider(thickness: 2),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.place, color: Colors.black),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Distance: $distanceDisplay',
                        style: GoogleFonts.getFont(
                          "Lexend",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _openMapRoute(startLatitude, startLongitude, endLatitude, endLongitude);
                      },
                      icon: Icon(Icons.directions, color: Colors.blue),
                      label: Text(
                        'Route',
                        style: GoogleFonts.getFont(
                          "Lexend",
                          color: Colors.blue
                        ),
                      ),
                    ),
                  ],
                ),

                
                Row(
                  children: [
                    Icon(Icons.telegram, color: Colors.black),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ph: ${locationDetails['phone']}',
                        style: GoogleFonts.getFont(
                          "Lexend",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => launch('tel:${locationDetails['phone']}'),
                      icon: Icon(Icons.call, color: Colors.blue),
                      label: Text(
                        ' Call ',
                        style: GoogleFonts.getFont(
                          "Lexend",
                          color: Colors.blue
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22),
                Text(
                  'Available Assistance:',
                  style: GoogleFonts.getFont(
                    "Lexend",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                ...locationDetails['help'].map<Widget>((helpItem) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '• $helpItem',
                      style: GoogleFonts.getFont(
                        "Lexend",
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMapRoute(double startLat, double startLng, double endLat, double endLng) async {
    String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
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

  Set<Marker> _getMarkersForMap() {
    Set<Marker> markers = {};

    if (!isHelping) {
      if (selectedFilter.isEmpty || selectedFilter == "Hospital") {
        markers.addAll(_hospitals);
      }
      if (selectedFilter.isEmpty || selectedFilter == "Relief Camp") {
        markers.addAll(_reliefCamps);
      }
      if (selectedFilter.isEmpty || selectedFilter == "Supplies") {
        markers.addAll(_supplies);
      }
      if (selectedFilter.isEmpty || selectedFilter == "Safe Space") {
        markers.addAll(_shelters);
      }
    } else {
      if (selectedFilter.isEmpty || selectedFilter == "Volunteer") {
        markers.addAll(_volunteers);
      }
      if (selectedFilter.isEmpty || selectedFilter == "Food") {
        markers.addAll(_food);
      }

      // Add more conditions here for other 'give' types if necessary
    }

    return markers;
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

  // dynamic actionButtonClickFn() {
  //   // Placeholder function to print the details
  //   print("-------------------------------------------------------------------------------------------------");
  //   print('Current Location: $currentLocation');
  //   print('Selected Filter: $selectedFilter');
  //   print('Selected Mode: ${isHelping ? "Helping" : "Need Help"}');
    
  // }

  // -----------------------------------------------------------------------------------------------------------------------------------------------
  // void actionButtonClickFn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String phoneNumber = prefs.getString('phoneNumber') ?? 'No phone number set';

  //   Map<String, IconData> helpIcons = isHelping
  //       ? {
  //           'Volunteer': Icons.volunteer_activism,
  //           'Donate': Icons.monetization_on,
  //           'Provide Shelter': Icons.home,
  //           'Offer Food': Icons.food_bank,
  //         }
  //       : {
  //           'Medical': Icons.medical_services,
  //           'Shelter': Icons.house,
  //           'Food': Icons.fastfood,
  //           'Clothing': Icons.checkroom,
  //           'Other': Icons.help_outline,
  //         };

  //   List<String> selectedHelp = [];

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
  //     ),
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setModalState) {
  //           return Padding(
  //             padding: EdgeInsets.all(40),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Text(
  //                   isHelping ? ' I can provide' : ' I need',
  //                   style: GoogleFonts.getFont(
  //                     "Lexend",
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 20,
  //                   ),
  //                 ),
  //                 Divider(),
  //                 SizedBox(height: 10),
  //                 ...helpIcons.keys.map((option) => CheckboxListTile(
  //                       title: Text(option, style: GoogleFonts.getFont(
  //                         "Lexend",
  //                       )),
  //                       value: selectedHelp.contains(option),
  //                       onChanged: (bool? value) {
  //                         setModalState(() {
  //                           if (value == true) {
  //                             selectedHelp.add(option);
  //                           } else {
  //                             selectedHelp.remove(option);
  //                           }
  //                         });
  //                       },
  //                       secondary: Icon(helpIcons[option]),
  //                     )),
  //                 SizedBox(height: 20),
  //                 Center(
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       shape: StadiumBorder(),
  //                       primary: isHelping ? Colors.blue : Colors.red,
  //                       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
  //                     ),
  //                     child: Text(
  //                       'Submit',
  //                       style: GoogleFonts.getFont(
  //                         "Lexend",
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 18,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     onPressed: () {
  //                       // Here you can handle the submission to backend or shared preferences
  //                       print('Action Button Pressed with the following selections:');
  //                       print('Phone Number: $phoneNumber');
  //                       print('Current Location: $currentLocation');
  //                       print('Selected Help Options: $selectedHelp');
  //                       Navigator.pop(context); // To close the modal bottom sheet
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }


void actionButtonClickFn() async {
  final prefs = await SharedPreferences.getInstance();
  String phoneNumber = prefs.getString('phoneNumber') ?? 'No phone number set';

  Map<String, IconData> helpIcons = {
    'Volunteer': Icons.volunteer_activism,
    'Donate': Icons.monetization_on,
    'Provide Shelter': Icons.house,
    'Offer Food': Icons.food_bank,
    'Medical': Icons.medical_services,
    'Shelter': Icons.house,
    'Food': Icons.fastfood,
    'Clothing': Icons.checkroom,
    'Other': Icons.help_outline,
  };

  Map<String, bool> helpOptions = Map.fromIterable(
    isHelping ? helpIcons.keys.take(4) : helpIcons.keys.skip(4),
    key: (item) => item as String,
    value: (item) => false,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListView(
                  controller: controller,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            isHelping ? ' I can provide' : ' I need',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Divider(),
                          ...helpOptions.keys.map((option) {
                            final isSelected = helpOptions[option]!;
                            return InkWell(
                              onTap: () {
                                setModalState(() {
                                  helpOptions[option] = !isSelected;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                                      : Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(helpIcons[option], color: Colors.grey[600]),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: GoogleFonts.lexend(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check, color: Theme.of(context).primaryColor),
                                  ],
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              primary: isHelping ? Colors.blue : Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: Text(
                              'Submit',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              List<String> selectedHelp = helpOptions.entries
                                  .where((entry) => entry.value)
                                  .map((entry) => entry.key)
                                  .toList();
                              // Handle the submission logic here
                              print('Phone Number: $phoneNumber');
                              print('Selected Help Options: $selectedHelp');
                              Navigator.pop(context); // Close the modal bottom sheet
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        initialChildSize: 0.55, // Adjust the initial height of the modal
        minChildSize: 0.1,     // Adjust the minimum height the modal can shrink to
        maxChildSize: 0.6,     // Adjust the maximum height the modal can grow to
      );
    },
  );
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
          locationLoaded
              ? GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: currentCameraPosition,
                  onCameraMove: (position) => currentCameraPosition = position,
                  zoomControlsEnabled: false,
                  markers: _getMarkersForMap(),
                )
              : Center(child: CircularProgressIndicator()),
          Column(
            children: [
              _buildTopFloatingBar(),
              _buildFilterBar(),
            ],
          ),
          recenterBtn(_controllerCompleter, currentLocation),
          actionBtn(isHelping, currentLocation, selectedFilter),
        ],
      ),
    );
  }
}