import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For custom icons
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final jsonString = await rootBundle.loadString('assets/weatherData.json');
    final jsonData = json.decode(jsonString);
    setState(() {
      weatherData = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: weatherData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    // Display the colored dot above the icon
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getColor(weatherData['Color']),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Display the weather icon and description
                    Icon(
                      _getWeatherIcon(weatherData['weather']),
                      size: 150,
                    ),
                    Text(
                      weatherData['weather'],
                      style: TextStyle(
                        fontFamily: GoogleFonts.kanit().fontFamily,
                        fontSize: 35,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Display the precautions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '      Precautions:',
                          style: TextStyle(
                            fontFamily: GoogleFonts.kanit().fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              _buildPrecautionItems(weatherData['Precautions']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Function to map weather description to FontAwesome icons
  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'partly cloudy':
        return FontAwesomeIcons.cloudSun;
      case 'sunny':
        return FontAwesomeIcons.sun;
      case 'rainy':
        return FontAwesomeIcons.cloudShowersHeavy;
      // Add more cases for other weather conditions
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }

  // Function to map color string to Color object
  Color _getColor(String color) {
    switch (color.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      // Add more cases for other colors
      default:
        return Colors.transparent;
    }
  }

  // Function to build list of precaution items
  List<Widget> _buildPrecautionItems(List<dynamic> precautions) {
    return precautions
        .map((precaution) => ListTile(
              leading: Icon(Icons.circle),
              title: Text(
                precaution,
                style: TextStyle(
                  fontFamily: GoogleFonts.kanit().fontFamily,
                ),
              ),
            ))
        .toList();
  }
}
