import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'predictionforcast_screen.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService _weatherService = WeatherService();
  late Future<Map<String, dynamic>> _weatherData;

  @override
  void initState() {
    super.initState();
    _weatherData = _weatherService.getWeather('Jabalpur'); // You can change the city here
  }

  Widget _buildModernWeatherCard(String title, String value, IconData icon, Color color, String unit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Optional: Add a tap effect or navigate to more details
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 36, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          "Jabalpur Weather", // Updated to reflect location
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final temp = data['main']['temp'].toStringAsFixed(1);
            final humidity = data['main']['humidity'].toString();
            final pressure = (data['main']['pressure'] / 100).toStringAsFixed(1);
            final weatherDescription = data['weather'][0]['description'];

            IconData weatherIcon;
            Color weatherColor;

            // Choose icon and color based on weather description
            if (weatherDescription.contains('rain')) {
              weatherIcon = Icons.cloudy_snowing;
              weatherColor = Colors.indigo;
            } else if (weatherDescription.contains('cloud')) {
              weatherIcon = Icons.cloud;
              weatherColor = Colors.grey;
            } else if (weatherDescription.contains('clear')) {
              weatherIcon = Icons.wb_sunny;
              weatherColor = Colors.orange;
            } else {
              weatherIcon = Icons.wb_cloudy;
              weatherColor = Colors.blueGrey;
            }


            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _buildModernWeatherCard("Temperature", temp, Icons.thermostat, Colors.redAccent, "°C"),
                  _buildModernWeatherCard("Humidity", humidity, Icons.water_drop, Colors.blueAccent, "%"),
                  _buildModernWeatherCard("Pressure", pressure, Icons.speed, Colors.greenAccent.shade700, "hPa"),
                  _buildModernWeatherCard("Condition", weatherDescription, weatherIcon, weatherColor, ""),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No weather data available'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PredictionScreen(),
          ));
        },
        icon: const Icon(Icons.umbrella_outlined, color: Colors.white),
        label: const Text('Rain Prediction', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.deepPurpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}