import 'package:flutter/material.dart';

class CurrentPredictionScreen extends StatelessWidget {
  const CurrentPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Current Rain Prediction"), backgroundColor: Colors.blueAccent),
      body: const Center(
        child: Text("🌧 Current Rain Prediction Data will appear here.", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
