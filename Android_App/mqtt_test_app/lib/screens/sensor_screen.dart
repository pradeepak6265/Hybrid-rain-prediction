import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/mqtt_service.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final MqttService _mqttService = MqttService();
  String _temp = "--";
  String _hum = "--";
  String _pres = "--";

  List<FlSpot> _tempData = [];
  List<FlSpot> _humData = [];
  List<FlSpot> _presData = [];
  int _timeIndex = 0;

  @override
  void initState() {
    super.initState();
    _mqttService.connect().then((_) {
      _mqttService.subscribeAndListen("esp32/sensor", (Map<String, dynamic> data) {
        setState(() {
          _temp = data['temp']?.toStringAsFixed(2) ?? "--";
          _hum = data['hum']?.toStringAsFixed(2) ?? "--";
          _pres = data['pres']?.toStringAsFixed(2) ?? "--";

          double tempValue = double.tryParse(_temp) ?? 0;
          double humValue = double.tryParse(_hum) ?? 0;
          double presValue = double.tryParse(_pres) ?? 0;

          // Add new data point to graph
          _tempData.add(FlSpot(_timeIndex.toDouble(), tempValue));
          _humData.add(FlSpot(_timeIndex.toDouble(), humValue));
          _presData.add(FlSpot(_timeIndex.toDouble(), presValue));
          _timeIndex++;

          // Keep the graph data size manageable (last 5 points for 5 minutes)
          if (_tempData.length > 5) _tempData.removeAt(0);
          if (_humData.length > 5) _humData.removeAt(0);
          if (_presData.length > 5) _presData.removeAt(0);
        });
      });
    });
  }

  @override
  void dispose() {
    _mqttService.client.disconnect();
    super.dispose();
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color, String unit) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('$value $unit', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraph(String title, List<FlSpot> spots, Color color, double minY, double maxY, String unit) {
    // Dynamically calculate y-axis range based on current data
    if (spots.isNotEmpty) {
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 2;
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 2;
    }

    // Set a min-max range if data is empty or constant to prevent errors
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 4, // Fixed range for last 5 data points (0 to 4)
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<FlSpot> touchedSpots) {
                        return touchedSpots.map((FlSpot spot) {
                          return LineTooltipItem(
                            'Current: ${spot.y.toStringAsFixed(1)} $unit',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1, // Show titles at 1-minute intervals
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt() + 1}m', style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: const Color(0xff37434d), strokeWidth: 1, dashArray: [2, 4]);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(color: const Color(0xff37434d), strokeWidth: 1, dashArray: [2, 4]);
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.3),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("🌦 Sensor Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSensorCard("Temperature", _temp, Icons.thermostat, Colors.red, "°C"),
                _buildSensorCard("Humidity", _hum, Icons.water_drop, Colors.blue, "%"),
                _buildSensorCard("Pressure", _pres, Icons.speed, Colors.green, "hPa"),
              ],
            ),
            _buildGraph("Temperature Trend", _tempData, Colors.red, 0, 55, "°C"),
            _buildGraph("Humidity Trend", _humData, Colors.blue, 0, 100, "%"),
            _buildGraph("Pressure Trend", _presData, Colors.green, 950, 1050, "hPa"),
          ],
        ),
      ),
    );
  }
}