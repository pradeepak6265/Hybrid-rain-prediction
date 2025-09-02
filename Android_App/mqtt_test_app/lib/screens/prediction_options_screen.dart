import 'package:flutter/material.dart';
import 'current_prediction_screen.dart';
import 'future_prediction_screen.dart';
import 'past_prediction_screen.dart';

class PredictionOptionsScreen extends StatelessWidget {
  const PredictionOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Options"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CurrentPredictionScreen()),
                );
              },
              icon: const Icon(Icons.cloud),
              label: const Text("Current Rain Prediction"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FuturePredictionScreen()),
                );
              },
              icon: const Icon(Icons.cloud_queue),
              label: const Text("Future Rain Prediction"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PastPredictionScreen()),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text("Past Rain Predicted"),
            ),
          ],
        ),
      ),
    );
  }
}
