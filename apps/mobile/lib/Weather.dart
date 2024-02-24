import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Map<String, dynamic> weatherData = {};
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _initializeNotifications();
    _startPeriodicNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Future<void> _loadWeatherData() async {
  //   final jsonString = await rootBundle.loadString('assets/weatherData.json');
  //   final jsonData = json.decode(jsonString);
  //   setState(() {
  //     weatherData = jsonData;
  //   });

  Future<void> _loadWeatherData() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final response = await http.get(Uri.parse(FlutterConfig.get('BACKEND_URL')+ '/api/gemini?city='+position.latitude.toString()+','+position.longitude.toString()));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      setState(() {
        weatherData = jsonData;
      });
    } else {
      _loadWeatherData();
    }
  }

  Future<void> _showNotification() async {
    final color = weatherData['Color'];
    final alert = weatherData['Alert'];
    final time = weatherData['Time'];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weather_channel',
      'Weather Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      '$color Alert',
      '$alert in $time hrs. Click to know more.',
      platformChannelSpecifics,
      payload: 'Weather',
    );
  }

  Future<void> _startPeriodicNotifications() async {
    await Future.delayed(Duration(minutes: 20));
    if (weatherData['Color'].toString().toLowerCase() != 'white') {
      _showNotification();
    }
    _startPeriodicNotifications();
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'partly cloudy':
        return FontAwesomeIcons.cloudSun;
      case 'sunny':
        return FontAwesomeIcons.sun;
      case 'rainy':
        return FontAwesomeIcons.cloudShowersHeavy;
      case 'thunderstorm':
        return FontAwesomeIcons.bolt;
      case 'snowy':
        return FontAwesomeIcons.snowflake;
      case 'windy':
        return FontAwesomeIcons.wind;
      case 'foggy':
        return FontAwesomeIcons.smog;
      case 'hail':
        return FontAwesomeIcons.cloudMeatball;
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }

  Color _getColor(String color) {
    switch (color.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  List<Widget> _buildPrecautionItems(List<dynamic> precautions) {
    return precautions
        .map(
          (precaution) => Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
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
                const SizedBox(height: 4),
              ],
            ),
          ),
        )
        .toList();
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
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
}
