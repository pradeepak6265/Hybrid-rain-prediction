import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final WeatherService _weatherService = WeatherService();
  String _currentPrediction = "Tap for Current Prediction";
  List<String> _futurePredictions = ["Tap for Future Prediction"];
  bool _isLoadingCurrent = false;
  bool _isLoadingFuture = false;

  Future<void> _getCurrentPrediction() async {
    setState(() {
      _isLoadingCurrent = true;
      _currentPrediction = "Fetching data...";
    });
    try {
      final data = await _weatherService.getWeather('New Delhi');
      final description = data['weather'][0]['description'];
      setState(() {
        _currentPrediction = description;
      });
    } catch (e) {
      setState(() {
        _currentPrediction = "Error fetching prediction";
      });
    } finally {
      setState(() {
        _isLoadingCurrent = false;
      });
    }
  }

  Future<void> _getFuturePrediction() async {
    setState(() {
      _isLoadingFuture = true;
      _futurePredictions = ["Fetching data..."];
    });
    try {
      final data = await _weatherService.getFutureWeather('New Delhi');
      List<String> futureForecasts = [];
      for (var item in data['list']) {
        final time = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final description = item['weather'][0]['description'];
        if (description.contains('rain') || description.contains('drizzle')) {
          futureForecasts.add(
              '${DateFormat('EEEE, h a').format(time)}: $description'
          );
        }
      }
      setState(() {
        _futurePredictions = futureForecasts.isNotEmpty ? futureForecasts : ["No rain expected in the next 36 hours."];
      });
    } catch (e) {
      setState(() {
        _futurePredictions = ["Error fetching future predictions."];
      });
    } finally {
      setState(() {
        _isLoadingFuture = false;
      });
    }
  }

  Widget _buildPredictionBox(String title, String content, VoidCallback onTap, bool isLoading) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
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
          'Rain Prediction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  _buildPredictionBox(
                    'Current\nPrediction',
                    _currentPrediction,
                    _getCurrentPrediction,
                    _isLoadingCurrent,
                  ),
                  _buildPredictionBox(
                    'Future\nPrediction',
                    "Tap to see\nnext 36 hours",
                    _getFuturePrediction,
                    _isLoadingFuture,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.builder(
                      itemCount: _futurePredictions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _futurePredictions[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: _futurePredictions[index].contains('No rain') ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
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