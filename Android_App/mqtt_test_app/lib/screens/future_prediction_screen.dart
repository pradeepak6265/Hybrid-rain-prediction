import 'package:flutter/material.dart';

class FuturePredictionScreen extends StatelessWidget {
  const FuturePredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Future Rain Prediction"), backgroundColor: Colors.blueAccent),
      body: const Center(
        child: Text("🌦 Future Rain Prediction Data will appear here.", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
