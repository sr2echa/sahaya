import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For custom icons
import 'dart:convert';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
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

    // final jsonString = 
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
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 0.1),
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
                  const SizedBox(height: 40),
                  // Display the weather icon and description
                  Icon(
                    _getWeatherIcon(weatherData['weather']),
                    size: 150,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    weatherData['weather'],
                    style: TextStyle(
                      fontFamily: GoogleFonts.kanit().fontFamily,
                      fontSize: 35,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: 250,
                    height: 35,
                    decoration: ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'In ${weatherData["Time"]} hrs',
                        style: GoogleFonts.kanit(
                          textStyle:const  TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Display the precautions
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildPrecautionItems(
                                weatherData['Precautions']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
        .map(
          (precaution) => Padding(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.5), // Adjust the value as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0), // Adjust the horizontal padding
                  dense: true,
                  leading: Icon(Icons.circle, size: 10),
                  title: Text(
                    precaution,
                    style: TextStyle(
                      fontFamily: GoogleFonts.kanit().fontFamily,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4), // Adjust the height as needed
              ],
            ),
          ),
        )
        .toList();
  }
}
