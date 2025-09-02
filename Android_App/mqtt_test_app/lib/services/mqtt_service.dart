import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient client = MqttServerClient('broker.hivemq.com', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');

  Future<void> connect() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onConnected = () => print("✅ Connected to MQTT broker");
    client.onDisconnected = () => print("❌ Disconnected from MQTT broker");
    client.onSubscribed = (String topic) => print('✅ Subscribed to $topic');
    client.onUnsubscribed = (String? topic) => print('✅ Unsubscribed from $topic');
    client.onSubscribeFail = (String topic) => print('❌ Failed to subscribe $topic');

    try {
      await client.connect();
    } on Exception catch (e) {
      print('⚡ Connection failed: $e');
      client.disconnect();
    }
  }

  void subscribeAndListen(String topic, Function(Map<String, dynamic>) onMessage) {
    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print("📩 Received on $topic: $pt");
      try {
        final Map<String, dynamic> data = jsonDecode(pt);
        onMessage(data);
      } catch (e) {
        print("⚠️ Error decoding JSON: $e");
      }
    });
  }
}



