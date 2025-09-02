import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  // यहाँ आपने जो URL कॉपी किया था, उसे पेस्ट करें
  final String _url = 'https://script.google.com/macros/s/AKfycbzOp8EnLnc4aJy_GwOY5TNky9szwuhHYWgZzhL1KTw7JVT7I1VTVCmIU-IHZg4tXkg_Vw/exec';

  Future<void> sendData({
    required Map<String, dynamic> sensorData,
    required Map<String, dynamic> apiData,
  }) async {
    final Map<String, dynamic> payload = {
      'sensor_data': sensorData,
      'api_data': apiData,
    };

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        print("✅ Data successfully sent to Google Sheets");
      } else {
        print("❌ Failed to send data. Status code: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error sending data: $e");
    }
  }
}