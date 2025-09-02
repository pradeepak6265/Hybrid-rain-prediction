import 'package:flutter/material.dart';
import 'prediction_options_screen.dart'; // नया screen import
import 'forecast_screen.dart'; // API data वाला screen import
import 'sensor_screen.dart'; // नया sensor screen import

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeMenu, // कहीं भी tap → menu close
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: Stack(
          children: [
            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloudy_snowing, size: 100, color: Colors.blueAccent), // rainy cloud symbol
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome to Hybrid Rain Prediction",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Stay Ahead of the Rain, Stay Safe.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PredictionOptionsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Get Started", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Button + Dropdown
            Positioned(
              top: 40,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu button
                  GestureDetector(
                    onTap: _toggleMenu,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.menu, size: 28, color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dropdown menu
                  if (_isMenuOpen)
                    Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.sensors, color: Colors.blueAccent),
                            label: const Text("Sensor Data"),
                            onPressed: () {
                              _closeMenu();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SensorScreen()),
                              );
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.cloud, color: Colors.blueAccent),
                            label: const Text("Forecast Data"),
                            onPressed: () {
                              _closeMenu();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForecastScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


