import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '8fca9ec9c1971957c2a1c12c4403c205';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather data');
    }
  }

  Future<Map<String, dynamic>> getFutureWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load future weather data');
    }
  }
}
