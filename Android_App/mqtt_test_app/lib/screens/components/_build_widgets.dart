// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// Widget buildSensorCard(String title, String value, IconData icon, Color color, String unit) {
//   return Card(
//     elevation: 6,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     child: Container(
//       height: 180,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.9), color.withOpacity(0.5)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 48, color: Colors.white),
//             const SizedBox(height: 10),
//             Text(title, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 5),
//             Text('$value $unit', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// Widget buildGraph(String title, List<FlSpot> spots, Color color) {
//   return Card(
//     elevation: 6,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     margin: const EdgeInsets.all(16),
//     child: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//           Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//       const SizedBox(height: 10),
//       SizedBox(
//         height: 250,
//         child: LineChart(
//           LineChartData(
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 30,
//                   interval: 1,
//                   getTitlesWidget: (value, meta) {
//                     return SideTitleWidget(
//                       axisSide: meta.axisSide,
//                       space: 8,
//                       child: Text('${value.toInt()}m', style: const TextStyle(fontSize: 12)),
//                     );
//                   },
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     return SideTitleWidget(
//                       axisSide: meta.axisSide,
//                       space: 8,
//                       child: Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
//                     );
//                   },
//                 ),
//               ),
//               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(color: const Color(0xff37434d), width: 1),
//             ),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: true,
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(color: const Color(0xff37434d), strokeWidth: 1, dashArray: [2, 4]);
//               },
//               getDrawingVerticalLine: (value) {
//                 return FlLine(color: const Color(0xff37434d), strokeWidth: 1, dashArray: [2, 4]);
//               },
//             ),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: spots,
//                 isCurved: true,
//                 color: color,
//                 barWidth: 3,
//                 dotData: FlDotData(show: false),
//                 belowBarData: BarAreaData(
//                   show: true,
//                   color: color.withOpacity(0.3),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         ],
//       ),
//     ),
//   ),
//   );
//}