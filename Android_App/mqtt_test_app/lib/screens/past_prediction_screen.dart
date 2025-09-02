import 'package:flutter/material.dart';

class PastPredictionScreen extends StatelessWidget {
  const PastPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Past Rain Predicted"), backgroundColor: Colors.blueAccent),
      body: const Center(
        child: Text("⛈ Past Rain Prediction Data will appear here.", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
